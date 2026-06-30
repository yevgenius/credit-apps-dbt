-- Grain: one row per status-change event as logged by the source system(s).
-- Deliberately NOT deduped here - that's a business decision (which occurrence
-- counts as authoritative) and belongs in intermediate/, not staging. Staging
-- only does type-cleaning and light normalization.

with source as (

    select * from {{ ref('raw_application_status_events') }}

),

cleaned as (

    select
        event_id,
        application_id,
        upper(trim(status)) as status,
        status_at::timestamp as status_at,
        nullif(upper(trim(decision_outcome)), '') as decision_outcome,
        nullif(upper(trim(decline_reason_code)), '') as decline_reason_code,
        event_source

    from source

)

select * from cleaned
