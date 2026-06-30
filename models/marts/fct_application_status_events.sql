-- Grain: one row per status-change event (same grain as the source event
-- log). Use this when a question needs event-level detail that
-- fct_applications collapses away - e.g. "how many UNDERWRITING events did
-- this application generate" or "what's the full timeline for app X."
-- For funnel/conversion/cycle-time questions, use fct_applications instead.

with events as (

    select * from {{ ref('stg_application_status_events') }}

),

applications as (

    select application_id, product_type, channel
    from {{ ref('stg_applications') }}

),

joined as (

    select
        events.event_id,
        events.application_id,
        applications.product_type,
        applications.channel,
        events.status,
        events.status_at,
        events.decision_outcome,
        events.decline_reason_code,
        events.event_source,
        row_number() over (
            partition by events.application_id
            order by events.status_at asc, events.event_id asc
        ) as event_sequence_number

    from events
    left join applications using (application_id)

)

select * from joined
