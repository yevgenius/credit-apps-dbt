"""
One-off generator for seed CSVs. Not part of the dbt project itself —
kept out of seeds/ on purpose. Run once, inspect/hand-edit the output,
then this script can be deleted. Documented here so the data's
provenance isn't a mystery later.
"""
import csv
from datetime import datetime, timedelta

def ts(s):
    return s  # already ISO strings below; kept as a hook for future formatting changes

apps = []
events = []

def add_app(app_id, applicant_id, product_type, channel, requested_amount, created_at, attributes="{}"):
    apps.append(dict(
        application_id=app_id, applicant_id=applicant_id, product_type=product_type,
        channel=channel, requested_amount=requested_amount, created_at=created_at,
        attributes=attributes,
    ))

def add_event(event_id, app_id, status, status_at, decision_outcome="", decline_reason_code="", event_source="loan_origination_system"):
    events.append(dict(
        event_id=event_id, application_id=app_id, status=status, status_at=status_at,
        decision_outcome=decision_outcome, decline_reason_code=decline_reason_code,
        event_source=event_source,
    ))

eid = 0
def nid():
    global eid
    eid += 1
    return f"EVT-{eid:05d}"

# 1: happy path, web, funded
add_app("APP-0001", "CUST-1001", "personal_loan", "web", 12000, "2026-06-01T09:00:00")
add_event(nid(), "APP-0001", "SUBMITTED", "2026-06-01T09:00:00")
add_event(nid(), "APP-0001", "UNDERWRITING", "2026-06-01T15:30:00")
add_event(nid(), "APP-0001", "DECISIONED", "2026-06-03T10:00:00", "APPROVED")
add_event(nid(), "APP-0001", "FUNDED", "2026-06-04T12:00:00")

# 2: declined - credit score
add_app("APP-0002", "CUST-1002", "personal_loan", "web", 8000, "2026-06-01T10:15:00")
add_event(nid(), "APP-0002", "SUBMITTED", "2026-06-01T10:15:00")
add_event(nid(), "APP-0002", "UNDERWRITING", "2026-06-01T18:00:00")
add_event(nid(), "APP-0002", "DECISIONED", "2026-06-02T09:45:00", "DECLINED", "CREDIT_SCORE_LOW")

# 3: declined - DTI high
add_app("APP-0003", "CUST-1003", "personal_loan", "mobile", 15000, "2026-06-02T08:00:00")
add_event(nid(), "APP-0003", "SUBMITTED", "2026-06-02T08:00:00")
add_event(nid(), "APP-0003", "UNDERWRITING", "2026-06-02T20:00:00")
add_event(nid(), "APP-0003", "DECISIONED", "2026-06-04T11:00:00", "DECLINED", "DTI_TOO_HIGH")

# 4: approved, explicitly withdrawn before funding
add_app("APP-0004", "CUST-1004", "personal_loan", "web", 20000, "2026-06-02T11:00:00")
add_event(nid(), "APP-0004", "SUBMITTED", "2026-06-02T11:00:00")
add_event(nid(), "APP-0004", "UNDERWRITING", "2026-06-02T16:00:00")
add_event(nid(), "APP-0004", "DECISIONED", "2026-06-04T09:00:00", "APPROVED")
add_event(nid(), "APP-0004", "WITHDRAWN", "2026-06-05T14:00:00")

# 5: approved, stuck pending funding (no terminal event yet - in progress)
add_app("APP-0005", "CUST-1005", "personal_loan", "partner", 9500, "2026-06-20T13:00:00")
add_event(nid(), "APP-0005", "SUBMITTED", "2026-06-20T13:00:00")
add_event(nid(), "APP-0005", "UNDERWRITING", "2026-06-20T19:00:00")
add_event(nid(), "APP-0005", "DECISIONED", "2026-06-22T10:00:00", "APPROVED")

# 6: withdrawn during underwriting
add_app("APP-0006", "CUST-1006", "personal_loan", "web", 5000, "2026-06-03T09:30:00")
add_event(nid(), "APP-0006", "SUBMITTED", "2026-06-03T09:30:00")
add_event(nid(), "APP-0006", "UNDERWRITING", "2026-06-03T15:00:00")
add_event(nid(), "APP-0006", "WITHDRAWN", "2026-06-04T08:00:00")

# 7: withdrawn immediately after submission
add_app("APP-0007", "CUST-1007", "personal_loan", "mobile", 3000, "2026-06-03T17:00:00")
add_event(nid(), "APP-0007", "SUBMITTED", "2026-06-03T17:00:00")
add_event(nid(), "APP-0007", "WITHDRAWN", "2026-06-03T17:45:00")

# 8: stuck in underwriting (in progress)
add_app("APP-0008", "CUST-1008", "personal_loan", "web", 11000, "2026-06-24T10:00:00")
add_event(nid(), "APP-0008", "SUBMITTED", "2026-06-24T10:00:00")
add_event(nid(), "APP-0008", "UNDERWRITING", "2026-06-24T16:00:00")

# 9: stuck just submitted (in progress, freshest)
add_app("APP-0009", "CUST-1009", "personal_loan", "web", 7000, "2026-06-26T09:00:00")
add_event(nid(), "APP-0009", "SUBMITTED", "2026-06-26T09:00:00")

# 10: expired during underwriting
add_app("APP-0010", "CUST-1010", "personal_loan", "branch", 6000, "2026-06-04T09:00:00")
add_event(nid(), "APP-0010", "SUBMITTED", "2026-06-04T09:00:00")
add_event(nid(), "APP-0010", "UNDERWRITING", "2026-06-04T14:00:00")
add_event(nid(), "APP-0010", "EXPIRED", "2026-06-19T00:00:00")

# 11: expired right after submission
add_app("APP-0011", "CUST-1011", "personal_loan", "web", 4000, "2026-06-05T12:00:00")
add_event(nid(), "APP-0011", "SUBMITTED", "2026-06-05T12:00:00")
add_event(nid(), "APP-0011", "EXPIRED", "2026-06-20T00:00:00")

# 12: happy path, mobile
add_app("APP-0012", "CUST-1012", "personal_loan", "mobile", 16000, "2026-06-05T08:30:00")
add_event(nid(), "APP-0012", "SUBMITTED", "2026-06-05T08:30:00")
add_event(nid(), "APP-0012", "UNDERWRITING", "2026-06-05T13:00:00")
add_event(nid(), "APP-0012", "DECISIONED", "2026-06-06T17:00:00", "APPROVED")
add_event(nid(), "APP-0012", "FUNDED", "2026-06-08T10:00:00")

# 13: happy path, partner, large amount
add_app("APP-0013", "CUST-1013", "personal_loan", "partner", 35000, "2026-06-06T09:00:00")
add_event(nid(), "APP-0013", "SUBMITTED", "2026-06-06T09:00:00")
add_event(nid(), "APP-0013", "UNDERWRITING", "2026-06-06T20:00:00")
add_event(nid(), "APP-0013", "DECISIONED", "2026-06-09T11:00:00", "APPROVED")
add_event(nid(), "APP-0013", "FUNDED", "2026-06-10T15:00:00")

# 14: duplicate UNDERWRITING event (retry/glitch), then approved + funded
add_app("APP-0014", "CUST-1014", "personal_loan", "web", 10000, "2026-06-07T09:00:00")
add_event(nid(), "APP-0014", "SUBMITTED", "2026-06-07T09:00:00")
add_event(nid(), "APP-0014", "UNDERWRITING", "2026-06-07T14:00:00", event_source="loan_origination_system")
add_event(nid(), "APP-0014", "UNDERWRITING", "2026-06-07T14:02:00", event_source="loan_origination_system_retry")
add_event(nid(), "APP-0014", "DECISIONED", "2026-06-09T10:00:00", "APPROVED")
add_event(nid(), "APP-0014", "FUNDED", "2026-06-10T09:00:00")

# 15: re-decisioned on appeal - DECLINED then later APPROVED, funded
add_app("APP-0015", "CUST-1015", "personal_loan", "web", 9000, "2026-06-08T09:00:00")
add_event(nid(), "APP-0015", "SUBMITTED", "2026-06-08T09:00:00")
add_event(nid(), "APP-0015", "UNDERWRITING", "2026-06-08T15:00:00")
add_event(nid(), "APP-0015", "DECISIONED", "2026-06-09T10:00:00", "DECLINED", "INSUFFICIENT_INCOME")
add_event(nid(), "APP-0015", "DECISIONED", "2026-06-12T10:00:00", "APPROVED", event_source="manual_override")
add_event(nid(), "APP-0015", "FUNDED", "2026-06-13T09:00:00")

# 16: null requested_amount, happy path funded anyway
add_app("APP-0016", "CUST-1016", "personal_loan", "web", "", "2026-06-09T09:00:00")
add_event(nid(), "APP-0016", "SUBMITTED", "2026-06-09T09:00:00")
add_event(nid(), "APP-0016", "UNDERWRITING", "2026-06-09T14:00:00")
add_event(nid(), "APP-0016", "DECISIONED", "2026-06-10T10:00:00", "APPROVED")
add_event(nid(), "APP-0016", "FUNDED", "2026-06-11T09:00:00")

# 17: created_at vs first SUBMITTED event mismatch (upstream lag), declined
add_app("APP-0017", "CUST-1017", "personal_loan", "web", 6500, "2026-06-09T08:00:00")  # note: created 1h before event logged
add_event(nid(), "APP-0017", "SUBMITTED", "2026-06-09T09:05:00")
add_event(nid(), "APP-0017", "UNDERWRITING", "2026-06-09T16:00:00")
add_event(nid(), "APP-0017", "DECISIONED", "2026-06-10T10:00:00", "DECLINED", "CREDIT_SCORE_LOW")

# 18: sequencing anomaly - FUNDED timestamp before DECISIONED timestamp (clock skew)
add_app("APP-0018", "CUST-1018", "personal_loan", "mobile", 12500, "2026-06-10T09:00:00")
add_event(nid(), "APP-0018", "SUBMITTED", "2026-06-10T09:00:00")
add_event(nid(), "APP-0018", "UNDERWRITING", "2026-06-10T14:00:00")
add_event(nid(), "APP-0018", "DECISIONED", "2026-06-12T11:00:00", "APPROVED")
add_event(nid(), "APP-0018", "FUNDED", "2026-06-12T08:00:00", event_source="core_banking")  # before decision ts - bad

# 19: declined for fraud
add_app("APP-0019", "CUST-1019", "personal_loan", "branch", 18000, "2026-06-11T09:00:00")
add_event(nid(), "APP-0019", "SUBMITTED", "2026-06-11T09:00:00")
add_event(nid(), "APP-0019", "UNDERWRITING", "2026-06-11T13:00:00")
add_event(nid(), "APP-0019", "DECISIONED", "2026-06-11T19:00:00", "DECLINED", "FRAUD_FLAG")

# 20: happy path baseline filler
add_app("APP-0020", "CUST-1020", "personal_loan", "web", 13500, "2026-06-12T09:00:00")
add_event(nid(), "APP-0020", "SUBMITTED", "2026-06-12T09:00:00")
add_event(nid(), "APP-0020", "UNDERWRITING", "2026-06-12T15:00:00")
add_event(nid(), "APP-0020", "DECISIONED", "2026-06-14T10:00:00", "APPROVED")
add_event(nid(), "APP-0020", "FUNDED", "2026-06-15T09:00:00")

with open("seeds/raw_applications.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["application_id","applicant_id","product_type","channel","requested_amount","created_at","attributes"])
    w.writeheader()
    w.writerows(apps)

with open("seeds/raw_application_status_events.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["event_id","application_id","status","status_at","decision_outcome","decline_reason_code","event_source"])
    w.writeheader()
    w.writerows(events)

print(f"{len(apps)} applications, {len(events)} events written.")
