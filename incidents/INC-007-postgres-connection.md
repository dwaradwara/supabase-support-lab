# INC-007 - External PostgreSQL authentication failure

## Classification

Foundational connectivity incident. A connection-pressure and pooling scenario
is planned for the advanced phase because an intentionally wrong password alone
does not demonstrate production-scale database support.

## Simulated customer ticket

> `psql` cannot connect through the Supabase Session Pooler and reports password
> authentication failure.

## Environment

- Windows PowerShell
- PostgreSQL `psql` client 16.14
- PostgreSQL server 17.6 in the original capture
- Supabase Session Pooler
- TLS connection

## Evidence and root cause

The same host, port, database and user failed with an intentionally incorrect
database password. The error occurred during authentication, so it did not prove
a DNS, routing or TLS failure.

## Fix and validation

The connection succeeded after the correct lab credential was supplied. The
session validated:

```sql
select current_database(), current_user;
select count(*) from public.support_tickets;
```

## Important distinction

A successful retry proves that the selected network path, TLS negotiation and
credentials worked for that test. It does not by itself diagnose pool saturation,
IPv4/IPv6 suitability, intermittent networking or application connection leaks.

## Version 2 evidence

The original screenshot was removed because it contained unrelated UI and
commands. A clean sanitized failure and success capture is pending.

## Planned advanced replacement

The stronger scenario will investigate intermittent connection exhaustion using
`pg_stat_activity`, application/state grouping, long transactions and Session vs
Transaction Pooler trade-offs. It will explicitly explain why simply increasing
connection limits may be the wrong fix.
