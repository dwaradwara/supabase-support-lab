# How to review this lab

This repository is a self-directed technical-support lab. It is evidence of deliberate preparation, not paid production Supabase support experience.

## Suggested review path

1. Read the [support method](../README.md#support-investigation-method) to see how each case is approached.
2. Review [INC-006 Storage authorization](../incidents/INC-006-storage-rls.md) for current hosted-project client evidence.
3. Review [INC-003 PostgreSQL performance](../incidents/INC-003-postgres-performance.md) for concrete query-plan evidence.
4. Review the [high-volume queue](../queue/QUEUE-001.md), then compare it with the [triage](../queue/QUEUE-001-triage.md) and [follow-up decisions](../queue/QUEUE-001-follow-up.md).
5. Read the [take-home response](../queue/TAKE-HOME-TKT-103-storage-upload.md) to evaluate customer communication and escalation judgment.
6. Review the [failed-hypothesis example](FAILED-HYPOTHESIS.md) to see how the investigation changes when evidence disproves the initial idea.

## What the author is demonstrating

- Layered troubleshooting across client, Auth, JWT, API, Storage, PostgreSQL, RLS, and connectivity.
- Evidence collection with SQL, HTTP status/body, query plans, logs, and `psql` output.
- Safe support behavior: secrets are not requested or stored, and security controls are not weakened as a shortcut.
- Explicit separation of confirmed facts, assumptions, limitations, and production recommendations.
- Customer-facing explanations that provide a next action without declaring an unverified root cause.

## What this lab does not prove

It does not prove real customer-ticket volume, SLA performance, production incident ownership, on-call experience, or years of Supabase experience. Those areas should be tested in interview questions or a live support simulation.

## Interview questions this lab supports

- “Walk me through the first five minutes of INC-006.”
- “Why did you test the effective request role instead of trusting the SQL Editor result?”
- “What evidence would change your priority for TKT-101?”
- “Tell me about a first hypothesis that the evidence disproved.”
- “Explain the difference between a public client key and a service-role key.”
