# Supabase Support Lab

Hands-on support engineering lab built around a hosted Supabase project. The goal was to reproduce realistic support incidents, collect evidence, diagnose root causes, apply fixes, and validate recovery.

## What this lab covers

- Supabase Data API / PostgREST
- PostgreSQL troubleshooting and query performance
- Row Level Security (RLS)
- Supabase Auth and JWT-based access
- Supabase Storage authorization
- Unified Logs / API Gateway correlation
- External PostgreSQL connectivity with `psql`
- Incident documentation and recovery validation

## Incident summary

| Incident | Symptom | Root cause | Recovery |
|---|---|---|---|
| INC-001 | Data API returned no rows although rows existed | RLS enabled with no matching SELECT policy | Added policy and verified rows returned |
| INC-002 | Login/API authorization failures | Malformed JSON, bad API key input, then invalid credentials | Corrected request, authenticated successfully, validated JWT + authenticated RLS |
| INC-003 | Single-row lookup scanned ~50k rows | Missing index on `customer_email` | Added B-tree index and verified indexed execution plan |
| INC-004 | Competing lock acquisition | Resource already held by another session | Demonstrated contention and recovery using PostgreSQL advisory locks |
| INC-005 | REST request returned HTTP 404 / PGRST205 | Misspelled table/resource in endpoint | Correlated API Gateway log and corrected endpoint to HTTP 200 |
| INC-006 | Storage upload denied | No matching `storage.objects` INSERT policy | Added authenticated bucket-scoped policy and verified HTTP 200 upload |
| INC-007 | External PostgreSQL login failed | Invalid database password | Retried with correct credentials and verified live DB access via Session Pooler |

## PostgreSQL performance evidence

Before indexing, the lookup on `customer_email` used a sequential scan and removed 50,003 rows by filter. After adding an index, PostgreSQL used the index path, shared buffer hits dropped from 703 to 4, and the captured execution time was 0.128 ms.

See:
- [`incidents/INC-003-postgres-performance.md`](incidents/INC-003-postgres-performance.md)
- [`evidence/screenshots/INC-003-before-seq-scan.png`](evidence/screenshots/INC-003-before-seq-scan.png)
- [`evidence/screenshots/INC-003-after-index.png`](evidence/screenshots/INC-003-after-index.png)

## Repository structure

```text
supabase-support-lab/
├── README.md
├── SECURITY.md
├── sql/
├── incidents/
├── runbooks/
└── evidence/
    └── screenshots/
```

## Security note

No passwords, JWTs, service-role keys, database passwords, or other secrets should be committed to this repository. Screenshots included here were selected to avoid exposing credentials.

## Environment

- Supabase hosted project
- PostgreSQL
- PowerShell / curl
- `psql`
- Supabase SQL Editor
- Supabase Unified Logs
