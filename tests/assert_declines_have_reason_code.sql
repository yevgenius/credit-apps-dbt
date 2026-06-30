-- A DECLINED decision with no decline_reason_code is a real upstream bug
-- (compliance/reporting need the reason, not just the outcome). Stays at
-- error severity - unlike the sequencing checks in _marts.yml, there's no
-- legitimate scenario where this should be null.

select *
from {{ ref('fct_applications') }}
where final_decision_outcome = 'DECLINED'
  and final_decline_reason_code is null
