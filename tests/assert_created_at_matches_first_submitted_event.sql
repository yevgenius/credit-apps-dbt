{{ config(severity = 'warn') }}

-- created_at on the application record and the first SUBMITTED event should
-- represent the same real-world moment, logged by two different systems.
-- A gap beyond a few minutes points to clock skew or ingestion lag worth
-- knowing about. warn, not error: APP-0017 in the seed data trips this on
-- purpose (~1hr gap) to demonstrate detection without failing the build.

select
    applications.application_id,
    applications.created_at,
    events.first_status_at as first_submitted_at,
    {{ dbt.datediff('applications.created_at', 'events.first_status_at', 'minute') }} as gap_minutes
from {{ ref('stg_applications') }} as applications
inner join {{ ref('int_application_status_events_deduped') }} as events
    on applications.application_id = events.application_id
    and events.status = 'SUBMITTED'
where abs({{ dbt.datediff('applications.created_at', 'events.first_status_at', 'minute') }}) > 5
