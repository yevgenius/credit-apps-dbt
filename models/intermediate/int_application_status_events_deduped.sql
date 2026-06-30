-- Collapses repeat events for the same (application_id, status) into one row.
--
-- Why dedupe here and not in staging: this is a business judgment call, not a
-- type-cleaning one. Two UNDERWRITING events 2 minutes apart (APP-0014) is a
-- system retry, not a meaningful state change - we want the FIRST occurrence
-- as the moment the application entered that stage. But a re-decisioning
-- after appeal (APP-0015: DECLINED, then APPROVED 3 days later) is a real
-- business event - we want the LATEST decision as the operative one. Both
-- "first" and "last" are computed here so the funnel model downstream can
-- pick whichever is right per status, without re-deriving this logic itself.

with events as (

    select * from {{ ref('stg_application_status_events') }}

),

ranked as (

    select
        *,
        row_number() over (
            partition by application_id, status
            order by status_at desc, event_id desc
        ) as rn_latest

    from events

),

deduped as (

    select
        application_id,
        status,
        min(status_at) as first_status_at,
        max(status_at) as last_status_at,
        count(*) as occurrence_count,
        max(case when rn_latest = 1 then decision_outcome end) as latest_decision_outcome,
        max(case when rn_latest = 1 then decline_reason_code end) as latest_decline_reason_code,
        max(case when rn_latest = 1 then event_source end) as latest_event_source

    from ranked
    group by 1, 2

)

select * from deduped
