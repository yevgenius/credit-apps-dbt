-- Grain: one row per application_id. This is the table downstream dashboards
-- should build on for anything funnel/conversion/cycle-time related.
--
-- Assumption: "current" funnel position is derived from the latest event per
-- application, not from a separate mutable status column on the application
-- record - there isn't one in our source data, and event-derived state is
-- more resilient to replays/backfills than a single overwritten column would
-- be (see README "Resilience" section).
--
-- Incremental strategy: merge on application_id. On each run only
-- applications with event activity in the last `incremental_lookback_days`
-- days are reprocessed. The lookback window (default 3 days) absorbs
-- late-arriving events; widen it if upstream systems have longer delays.
-- merge (not delete+insert) so this runs unmodified on Redshift, Snowflake,
-- and BigQuery - BigQuery doesn't support delete+insert at all.
-- depends_on: {{ ref('stg_application_status_events') }}
{{ config(
    materialized='incremental',
    unique_key='application_id',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
) }}

with applications as (

    select * from {{ ref('stg_applications') }}
    {% if is_incremental() %}
    where application_id in (
        select distinct application_id
        from {{ ref('stg_application_status_events') }}
        where status_at >= (
            select max(current_status_at) - interval '{{ var("incremental_lookback_days") }} days'
            from {{ this }}
        )
    )
    {% endif %}

),

funnel as (

    select * from {{ ref('int_application_funnel_stages') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

joined as (

    select
        applications.application_id,
        applications.applicant_id,
        applications.product_type,
        products.product_name,
        products.product_category,
        applications.channel,
        applications.requested_amount,
        applications.created_at,

        funnel.submitted_at,
        funnel.underwriting_started_at,
        funnel.first_decisioned_at,
        funnel.final_decision_at,
        funnel.decision_count,
        funnel.final_decision_outcome,
        funnel.final_decline_reason_code,
        funnel.funded_at,
        funnel.withdrawn_at,
        funnel.expired_at,
        funnel.current_status,
        funnel.current_status_at,

        -- outcome flags - kept as explicit booleans rather than asking every
        -- dashboard to re-derive them from raw timestamps
        (funnel.funded_at is not null) as is_funded,
        (funnel.final_decision_outcome = 'DECLINED') as is_declined,
        (funnel.withdrawn_at is not null) as is_withdrawn,
        (funnel.expired_at is not null) as is_expired,
        (coalesce(funnel.decision_count, 0) > 1) as was_redecisioned,

        -- furthest point reached along the happy path, regardless of how the
        -- application actually ended (declined/withdrawn/expired)
        case
            when funnel.funded_at is not null then 'FUNDED'
            when funnel.first_decisioned_at is not null then 'DECISIONED'
            when funnel.underwriting_started_at is not null then 'UNDERWRITING'
            when funnel.submitted_at is not null then 'SUBMITTED'
            else 'UNKNOWN'
        end as furthest_stage_reached,

        -- has this application reached an end state, or is it still active?
        case
            when funnel.funded_at is not null then true
            when funnel.withdrawn_at is not null then true
            when funnel.expired_at is not null then true
            when funnel.final_decision_outcome = 'DECLINED' then true
            else false
        end as is_terminal,

        -- stage durations in hours. dbt.datediff keeps this portable
        -- across warehouses instead of hand-rolling per-dialect date math.
        {{ dbt.datediff('funnel.submitted_at', 'funnel.underwriting_started_at', 'hour') }}
            as hours_submitted_to_underwriting,
        {{ dbt.datediff('funnel.underwriting_started_at', 'funnel.first_decisioned_at', 'hour') }}
            as hours_underwriting_to_decision,
        {{ dbt.datediff('funnel.final_decision_at', 'funnel.funded_at', 'hour') }}
            as hours_decision_to_funded,
        {{ dbt.datediff('funnel.submitted_at', 'funnel.funded_at', 'hour') }}
            as hours_submitted_to_funded

    from applications
    left join funnel on applications.application_id = funnel.application_id
    left join products on applications.product_type = products.product_type

),

final as (

    select
        *,
        -- Assumption: an application past stale_application_days (var, default
        -- 14) since its last event with no terminal outcome is probably stuck,
        -- not genuinely "in progress" - flagged for ops to chase, not auto-closed.
        -- NOTE: interval syntax below is DuckDB/Postgres-style; adjust for your
        -- warehouse (e.g. DATEADD on Snowflake/BigQuery) when porting.
        (
            not is_terminal
            and current_status_at < {{ dbt.current_timestamp() }} - interval '{{ var("stale_application_days") }} days'
        ) as is_stale

    from joined

)

select * from final
