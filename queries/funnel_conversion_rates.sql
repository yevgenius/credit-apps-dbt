-- What does the application funnel look like? Counts and conversion rates
-- at each stage, for the standard "funnel chart" dashboard view.

with base as (

    select * from {{ ref('fct_applications') }}

),

stage_counts as (

    select
        count(*) as submitted,
        count(*) filter (where underwriting_started_at is not null) as reached_underwriting,
        count(*) filter (where first_decisioned_at is not null) as reached_decision,
        count(*) filter (where is_funded) as funded
    from base

)

select
    submitted,
    reached_underwriting,
    round(100.0 * reached_underwriting / nullif(submitted, 0), 1) as pct_to_underwriting,
    reached_decision,
    round(100.0 * reached_decision / nullif(reached_underwriting, 0), 1) as pct_underwriting_to_decision,
    funded,
    round(100.0 * funded / nullif(reached_decision, 0), 1) as pct_decision_to_funded,
    round(100.0 * funded / nullif(submitted, 0), 1) as pct_overall_conversion
from stage_counts
