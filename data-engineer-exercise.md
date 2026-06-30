# Data Engineer Take-Home — Applications Data Model

> **Time budget:** ≤ 2 hours. We're more interested in the shape of your thinking than a polished, complete answer. Use AI tools however you normally would — we'll talk through your prompts and your judgment calls in the interview.

---

## The prompt

Build a **dbt data model for credit applications** that can serve as the foundation for downstream reporting and ad-hoc analytical questions about the application funnel.

You can assume the underlying warehouse contains whatever raw data you need. **You don't need to invent ingestion or model the source systems.** Your job starts at the bronze layer and ends at a model someone else can build a dashboard on top of.

The model should be:

- **Extensible**
- **Resilient**

---

## Deliverables

Submit a **GitHub repository** containing the following. The repo can be private — see Submission below for who to share it with.

### 1. The dbt model(s)

The actual SQL files, organized however you would in a real project. Include sources, staging/intermediate models if you'd want them, and the final mart-level model(s). Don't worry about wiring this to a real warehouse — we'll read the SQL.

### 2. Seed data + example queries

Include a small set of dbt seed files (CSVs in `seeds/`) that exercise the model — enough to make it runnable end-to-end and to cover at least a few interesting edge cases. Then include **a handful of queries** (3–5 is plenty) against the final mart that demonstrate it answers real questions about applications Drop these in a `queries/` or `analyses/` directory with a short comment at the top of each explaining what it answers.

### 3. Tests and anomaly detection

A meaningful set of tests that would catch the things you'd actually be worried about in production. Cover both static tests and anomaly detection.

### 4. README

Cover what you built and any assumptions you made.

### 5. AI / dev-velocity artifacts

Include anything in the repo that would help future you (or a teammate) build, edit, debug, extend, or operate this model faster. We're as interested in the **judgment** here as in the artifacts themselves — what was worth investing in, what wasn't, and why.

---

## A note on assumptions

We've left a lot of this prompt deliberately open-ended. There is no single right answer — there are many reasonable shapes a credible response could take. **Make your assumptions explicit inline** (a one-line "Assumption:" callout in the README or in a comment block at the top of each model is perfect) so we can talk through them in the interview. We care more about how you reason about the gaps than about you guessing what we have in mind.

---

## Submission

Push your work to a GitHub repository and share access with the interviewing team. A private repo is fine — please add the email addresses provided to you in the take-home invite as collaborators.

You can use any AI tool you'd like. **We'll ask you to walk us through your prompts, the artifacts you committed, and how you decided what to keep vs. throw out** — it's worth keeping rough notes.

Good luck — and don't over-build this. We'd rather see a partial answer with sharp instincts than a complete answer with hand-wavy reasoning.