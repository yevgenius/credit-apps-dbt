-- Why are applications getting declined? Breakdown of decline reasons,
-- for the underwriting/risk team.

select
    final_decline_reason_code,
    count(*) as declined_applications,
    round(100.0 * count(*) / sum(count(*)) over (), 1) as pct_of_declines
from {{ ref('fct_applications') }}
where is_declined
group by 1
order by declined_applications desc
