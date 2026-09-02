# Supabase Support Lab - Version 2

Support-engineering lab built around a disposable hosted Supabase project. The
lab reproduces customer-style failures, records evidence, tests competing
hypotheses, applies the smallest safe correction and validates both allowed and
denied behavior.

Version 2 is an active hardening branch. SQL and documentation marked **pending
validation** have been authored but must be executed against the hosted lab
before successful output is claimed.

## What this lab demonstrates

- Supabase Data API / PostgREST troubleshooting
- Auth request parsing, JWT context and owner-scoped RLS
- Storage authorization with bucket and user-folder restrictions
- PostgreSQL plans, selectivity, buffers and index trade-offs
- Real row-lock contention with blocker/waiter diagnosis
- External PostgreSQL connectivity and pooling fundamentals
- Customer-facing explanations and internal investigation notes
- Safe validation, negative tests and asynchronous escalation structure

## Support workflow

Each flagship incident follows this sequence:

```text
Customer impact
-> exact evidence
-> hypotheses and tests
-> root cause
-> smallest safe change
-> positive and negative validation
-> customer explanation
-> prevention / escalation
```

## Incident status

| Incident | Scenario | Version 2 status |
|---|---|---|
| [INC-001](incidents/INC-001-rls-data-api.md) | SQL Editor has rows; client returns `[]` | Owner-scoped rewrite complete; hosted validation pending |
| [INC-002](incidents/INC-002-auth-jwt-rls.md) | Auth/JWT succeeds but data access differs | Secure policy rewrite complete; hosted Auth validation pending |
| [INC-003](incidents/INC-003-postgres-performance.md) | Selective lookup scans about 50k rows | Reproducible SQL complete; clean plans pending |
| [INC-004](incidents/INC-004-lock-contention.md) | Update hangs behind an open transaction | Real blocker diagnostics complete; hosted evidence pending |
| [INC-005](incidents/INC-005-api-404-postgrest.md) | Data API returns PGRST205 | Foundational scenario retained; clean evidence pending |
| [INC-006](incidents/INC-006-storage-rls.md) | Private-bucket upload denied | User-folder policy complete; hosted allow/deny validation pending |
| [INC-007](incidents/INC-007-postgres-connection.md) | External PostgreSQL authentication fails | Foundational scenario retained; advanced pooling replacement planned |

## Security corrections in Version 2

The original learning version used `to authenticated using (true)` to prove that
an authenticated role could read through RLS. That policy allowed every signed-in
user to see every ticket and is not retained.

Version 2 adds `owner_id` and validates that:

- User A sees only User A rows.
- User B sees only User B rows.
- anonymous and unrelated users see no rows.
- Storage uploads are restricted to the authenticated user's folder.
- grants and policies are reviewed separately.

## Reproducing the lab

Read [SETUP.md](SETUP.md). Use only a disposable project. The reset script is
destructive and is not appropriate for production or shared databases.

Recommended order:

1. `sql/00-reset.sql`
2. `sql/schema.sql`
3. `sql/seed.sql`
4. `sql/rls-policies.sql`
5. `sql/rls-validation.sql`
6. the selected incident reproduction file

## Evidence policy

The original screenshots were removed from the Version 2 branch because they
included unrelated browser and desktop context. New evidence must be tightly
cropped, sanitized and generated from actual execution. See
[evidence/PENDING.md](evidence/PENDING.md).

No password, full JWT, refresh token, secret/service-role key or real customer
data belongs in this repository.

## Repository structure

```text
supabase-support-lab/
|-- README.md
|-- SETUP.md
|-- SECURITY.md
|-- sql/
|-- incidents/
|-- runbooks/
|-- templates/
`-- evidence/
```

## Current limitations

- This is a controlled learning lab, not Supabase internal production
  infrastructure.
- It does not reproduce real customer scale, private support tooling or internal
  engineering access.
- Synthetic JWT claims are used for deterministic SQL-only RLS tests.
- Version 2 evidence remains pending until the hosted scenarios are rerun.

These limitations are stated explicitly so the project demonstrates method and
judgment without claiming production experience it does not provide.
