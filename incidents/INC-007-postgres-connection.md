# INC-007 — External PostgreSQL connection / credential failure

## Symptom
External `psql` connection to Supabase PostgreSQL failed authentication.

## Environment
- Windows PowerShell
- PostgreSQL `psql` 16.14
- Supabase Session Pooler
- TLS connection

## Reproduction
A connection attempt was made through the Session Pooler using an intentionally incorrect database password.

## Evidence
`psql` returned a password authentication failure.

## Root cause
Invalid database password.

## Fix
Retried the same host, port, database and user with the correct database password.

## Recovery validation
The connection succeeded over TLS. The live database returned:

```sql
select current_database(), current_user;
```

and:

```sql
select count(*) from public.support_tickets;
```

The table contained 50,004 rows.

## Evidence
- [Successful external psql validation](../evidence/screenshots/INC-007-psql-success.png)

## Learning
Separate network/host/port problems from credential problems. Once connected, validate both session identity and an application table to prove end-to-end database access.
