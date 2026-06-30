-- How long does it take applications to get funded, broken out by channel?
-- Useful for spotting an underperforming intake channel (e.g. partner vs web).

select
    channel,
    count(*) as funded_applications,
    round(avg(hours_submitted_to_funded), 1) as avg_hours_submitted_to_funded,
    round(median(hours_submitted_to_funded), 1) as median_hours_submitted_to_funded,
    round(avg(hours_underwriting_to_decision), 1) as avg_hours_underwriting_to_decision
from {{ ref('fct_applications') }}
where is_funded
group by channel
order by avg_hours_submitted_to_funded desc
