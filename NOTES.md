# Build notes

Notes as requested

## Scoping decisions

- Applicatio nfunnel: `submitted -> underwriting -> decision -> funded`.
- Start with a single product, but the model has to be easily extensible -
  comments throughout explain *why* a given structure is extensible
- AI/dev-velocity artifact: `CLAUDE.md` plus this notes
  file - what the grain of a layer is, which conventions not to break, where
  the edge cases live. A prompt library for a project this size
  would be over-building relative to its payoff.

## Design decision worth flagging

The whole model hinges on treating applications as an **event log** rather
than a row with a mutable status column. This wasn't asked for explicitly,
but it's the most direct way to satisfy both "extensible" and "resilient".

## Seed data

20 synthetic applications, deliberately covering: happy paths across
channels, multiple decline reasons, an explicit withdrawal-after-approval,
an in-progress-and-stuck application, expirations, a duplicate event
(system retry noise), a re-decisioning/appeal case, a null amount, and two
specifically engineered data-quality issues (clock-skew sequencing bug,
created_at/event timestamp mismatch) that the warn-severity tests are
tuned to catch. Each one is commented in `_gen_seeds.py` with which
scenario it represents - that file isn't part of the dbt project itself,
it's just how the CSVs got built, kept for traceability.
