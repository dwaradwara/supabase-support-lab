# Supabase Support Lab

A hands-on, self-directed Support Engineering environment built in a hosted Supabase project to practice customer-impact triage, PostgreSQL diagnosis, Supabase product troubleshooting, escalation decisions, recovery validation, and incident documentation.

> **Important:** This is simulated lab work, not paid production Supabase support experience and not a collection of real customer incidents. The repository deliberately separates observed lab evidence, assumptions, and production recommendations.

## What this demonstrates

- Investigating the customer symptom before assuming the root cause
- Separating request, authentication, authorization, database, Storage, and connectivity layers
- Prioritizing by customer impact, scope, urgency, and safety
- Reproducing failures and collecting evidence with SQL, HTTP requests, logs, and `psql`
- Applying the smallest safe fix and validating the original failing path
- Writing customer updates, internal escalations, and handoff notes
- Explaining security and operational trade-offs instead of weakening controls blindly

## Support investigation method

Each incident follows the same support workflow:

1. Confirm the customer symptom and impact.
2. State what is known, unknown, and assumed.
3. Assign provisional severity and priority.
4. Reproduce the failure with one hypothesis at a time.
5. Capture evidence and identify the actual failing layer.
6. Apply the smallest safe remediation.
7. Re-run the original test and validate scope and security.
8. Communicate the result and document prevention or escalation.

The reusable structure is [`incidents/INCIDENT-TEMPLATE.md`](incidents/INCIDENT-TEMPLATE.md).

## Hiring-manager review path

Start with the [hiring-manager review guide](docs/HIRING-MANAGER-GUIDE.md), then inspect the [technical architecture](docs/ARCHITECTURE.md), [redacted request/response examples](evidence/REDACTED-REQUEST-RESPONSE-EXAMPLES.md), and the [high-volume queue exercise](queue/README.md). The queue includes initial triage, customer updates, escalation routing, changing priorities after new evidence, and a polished take-home response. The [failed-hypothesis example](docs/FAILED-HYPOTHESIS.md) shows how the investigation changes when evidence disproves the initial idea.

## Incident portfolio

| Incident | Support scenario | Evidence-backed result |
|---|---|---|
| [INC-001](incidents/INC-001-rls-data-api.md) | Data API returned no rows although PostgreSQL contained rows | RLS and request-role mismatch identified; lab recovery returned the expected rows |
| [INC-002](incidents/INC-002-auth-jwt-rls.md) | Login and protected Data API access failed at different layers | JSON, key, credentials, JWT, and RLS layers isolated separately |
| [INC-003](incidents/INC-003-postgres-performance.md) | Lookup scanned almost the entire table | B-tree index changed the plan; buffer hits fell from 703 to 4 |
| [INC-004](incidents/INC-004-lock-contention.md) | Competing sessions could not acquire a logical lock | Advisory-lock contention reproduced and recovery validated |
| [INC-005](incidents/INC-005-api-404-postgrest.md) | REST request returned HTTP 404 / `PGRST205` | API Gateway correlation identified a misspelled resource; corrected request returned HTTP 200 |
| [INC-006](incidents/INC-006-storage-rls.md) | Upload to a private Storage bucket was denied | Anonymous upload returned 403; authenticated end-user upload succeeded |
| [INC-007](incidents/INC-007-postgres-connection.md) | External `psql` connection failed authentication | Same Session Pooler target succeeded with corrected credentials and TLS validation |

## Strongest evidence

### RLS and authorization boundaries

INC-001 and INC-002 show why an empty Data API response does not automatically mean deleted data. The investigation compares database visibility with the effective request role and distinguishes authentication from authorization.

### PostgreSQL performance

In INC-003, `EXPLAIN (ANALYZE, BUFFERS)` showed a sequential scan, 50,003 rows removed by the filter, and 703 shared buffer hits. After the targeted index, PostgreSQL used an index condition, shared buffer hits fell to 4, and the captured execution time was 0.128 ms.

- [Before: sequential scan](evidence/screenshots/INC-003-before-seq-scan.png)
- [After: indexed lookup](evidence/screenshots/INC-003-after-index.png)

The before execution time and production customer latency were not captured, so this repository does not claim a specific end-user latency reduction.

### Storage authorization

INC-006 has current hosted-project client evidence:

- Unauthenticated upload: HTTP 403 with `new row violates row-level security policy`.
- Authenticated end-user upload: succeeded through the `authenticated` policy.
- Dashboard upload: also succeeded, but is treated separately because dashboard access may be privileged.

See the [validation record](evidence/INC-006-validation-2026-09-02.md). No passwords, keys, or JWTs are stored.

## Runbooks

- [Data API troubleshooting](runbooks/api-troubleshooting.md)
- [Auth troubleshooting](runbooks/auth-troubleshooting.md)
- [PostgreSQL connectivity](runbooks/postgres-connectivity.md)
- [PostgreSQL performance](runbooks/postgres-performance.md)
- [Storage access](runbooks/storage-access.md)

## Repository structure

```text
supabase-support-lab/
├── README.md
├── SECURITY.md
├── sql/                         Reproduction and remediation SQL
├── incidents/                   Incident records and reusable template
├── docs/                        Hiring-manager guide and architecture
├── queue/                       High-volume triage and take-home exercise
├── runbooks/                    Layer-specific troubleshooting checklists
├── tools/                       Temporary local validation client
└── evidence/                    Validation notes and screenshots
```

## Environment

- Supabase hosted project
- PostgreSQL
- PowerShell and `curl`
- PostgreSQL `psql`
- Supabase SQL Editor
- Supabase Unified Logs / API Gateway logs
- Temporary local browser client for the authenticated Storage test

## Security and honesty boundary

No passwords, user credentials, JWT access or refresh tokens, secret/service-role keys, database passwords, or credential-bearing connection strings belong in this repository. See [`SECURITY.md`](SECURITY.md).

The lab supports a claim of deliberate technical preparation and evidence-based troubleshooting. It does not support a claim of years of production Supabase support experience, real customer ticket ownership, SLA performance, or production incident management.
