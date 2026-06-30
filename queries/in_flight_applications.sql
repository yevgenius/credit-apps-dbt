-- Which applications are currently in-flight, and which of those look stale
-- (no activity in a while)? An ops queue, not a historical report.

select
    application_id,
    applicant_id,
    channel,
    current_status,
    current_status_at,
    requested_amount,
    is_stale
from {{ ref('fct_applications') }}
where not is_terminal
order by current_status_at asc
