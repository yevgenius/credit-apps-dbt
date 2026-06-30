-- Pivots the event log into one row per application_id, with one timestamp
-- column per funnel stage. This is the extensibility seam: adding a new
-- funnel stage (e.g. "OFFER_PRESENTED" between UNDERWRITING and DECISIONED)
-- means adding one new max(case when status = '...') line here and to the
-- accepted_values list in staging - no other model changes.
--
-- Incremental strategy: delete+insert on application_id. The recently_active
-- CTE applies the lookback filter before the group-by and the latest_event
-- window function, so neither runs over the full event table on each run.
{{ config(
    materialized='incremental',
    unique_key='application_id',
    incremental_strategy='delete+insert'
) }}

with recently_active as (

    -- Identifies which applications to reprocess. On first run returns every
    -- application; on incremental runs returns only those with event activity
    -- within the lookback window, anchored to this table's high-water mark.
    {% if is_incremental() %}
    select distinct application_id
    from {{ ref('stg_application_status_events') }}
    where status_at >= (
        select max(current_status_at) - interval '{{ var("incremental_lookback_days") }} days'
        from {{ this }}
    )
    {% else %}
    select distinct application_id
    from {{ ref('stg_application_status_events') }}
    {% endif %}

),

deduped as (

    select * from {{ ref('int_application_status_events_deduped') }} as d
    where d.application_id in (select recently_active.application_id from recently_active)

),

latest_event as (

    -- "Current status" is the most recent event of ANY type for the
    -- application, not the most recent occurrence of a given status -
    -- distinct from the per-status aggregation above.
    select
        application_id,
        status as current_status,
        status_at as current_status_at
    from (
        select
            *,
            row_number() over (
                partition by events.application_id
                order by events.status_at desc, events.event_id desc
            ) as rn
        from {{ ref('stg_application_status_events') }} as events
        where events.application_id in (select recently_active.application_id from recently_active)
    ) as ranked
    where rn = 1

),

pivoted as (

    select
        application_id,
        max(case when status = 'SUBMITTED' then first_status_at end) as submitted_at,
        max(case when status = 'UNDERWRITING' then first_status_at end) as underwriting_started_at,
        max(case when status = 'DECISIONED' then first_status_at end) as first_decisioned_at,
        max(case when status = 'DECISIONED' then last_status_at end) as final_decision_at,
        max(case when status = 'DECISIONED' then occurrence_count end) as decision_count,
        max(case when status = 'DECISIONED' then latest_decision_outcome end) as final_decision_outcome,
        max(case when status = 'DECISIONED' then latest_decline_reason_code end) as final_decline_reason_code,
        max(case when status = 'FUNDED' then first_status_at end) as funded_at,
        max(case when status = 'WITHDRAWN' then first_status_at end) as withdrawn_at,
        max(case when status = 'EXPIRED' then first_status_at end) as expired_at
    from deduped
    group by 1

)

select
    pivoted.*,
    latest_event.current_status,
    latest_event.current_status_at
from pivoted
left join latest_event on pivoted.application_id = latest_event.application_id
