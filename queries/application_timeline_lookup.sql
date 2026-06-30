-- Support/debugging query: "what actually happened to application X" -
-- full event-level timeline, in order. Swap the application_id below.

select
    event_sequence_number,
    status,
    status_at,
    decision_outcome,
    decline_reason_code,
    event_source
from {{ ref('fct_application_status_events') }}
where application_id = 'APP-0015'  -- example: the re-decisioned-on-appeal case
order by event_sequence_number
