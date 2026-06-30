# CLAUDE.md

Context for AI coding assistants (Claude Code, Cursor, etc.) working in this
repo. Keep this short - it should orient, not duplicate the README.

## What this is

A dbt project modeling a credit application funnel:
`SUBMITTED -> UNDERWRITING -> DECISIONED -> FUNDED`, with `WITHDRAWN`/`EXPIRED`
as exits. Read `README.md` first, especially "Why an event log instead of a
status column" - that decision shapes every model in here.

## Layer conventions (don't break these)

- **staging/**: 1:1 with a source/seed. Type-cleaning and renaming only.
  Never put business logic (dedup, joins across entities, derived flags)
  here.
- **intermediate/**: business logic lives here. Materialized `ephemeral` -
  not meant to be queried directly, so don't add tests that assume a
  physical table exists without checking `dbt_project.yml`.
- **marts/**: what dashboards/analysts actually query. `fct_applications`
  is the one row-per-application table; `fct_application_status_events` is
  the atomic event-grain table for "what happened, in order" questions.
  Don't add columns to `fct_applications` that only make sense at the
  event grain - that's what the events fact is for.

## Adding a new funnel stage

1. Add the value to `accepted_values` in `models/staging/_staging.yml`
   (on `stg_application_status_events.status`).
2. Add one `max(case when status = '...' then first_status_at end)` line
   to `models/intermediate/int_application_funnel_stages.sql`.
3. Decide if it needs a derived flag/duration in `fct_applications.sql`
   (most stages do - follow the existing pattern for the other stages).
4. Update the mermaid `stateDiagram-v2` in `README.md`.

## Adding a new product

Should require **zero** model changes - add a row to
`seeds/raw_products.csv` (or the real source table in production) and,
if needed, applications referencing it in `raw_applications`. If you find
yourself editing a `.sql` file to support a new product, something's
wrong with the design - flag it rather than special-casing it.

## Testing conventions

- `error` severity = should never happen, full stop (structural integrity,
  hard business rules).
- `warn` severity = "worth knowing, not worth blocking a build" - mostly
  cross-timestamp sequencing checks where upstream clock skew is a known
  possibility. A few of these are tuned to fire on the seed data on
  purpose (see README "Tests & anomaly detection") - don't "fix" the
  seeds to make warnings disappear without checking the README first.

## Local dev

```bash
dbt deps && dbt seed && dbt run && dbt test
```

DuckDB via `profiles.yml.example` - no warehouse needed.

## What I deliberately didn't build (don't add unless asked)

- `dim_applicants` - no real source data to model it credibly against.
- A second product's worth of real application data - `hardship_loan` exists
  in `dim_products` specifically to prove extensibility without needing
  fake application volume behind it.
