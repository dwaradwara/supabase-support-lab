# INC-004 — PostgreSQL lock contention

## Symptom
A second session could not acquire the same logical lock while another session held it.

## Reproduction
Session A acquired an advisory transaction lock and held it briefly:

```sql
select pg_advisory_xact_lock(424242);
select pg_sleep(30);
```

Session B attempted a non-blocking acquisition:

```sql
select pg_try_advisory_xact_lock(424242);
```

## Evidence
- While Session A held the lock, Session B returned `false`.
- After Session A released the lock, the same request returned `true`.

## Root cause
The logical resource was already locked by another PostgreSQL session.

## Recovery
The lock was released when the holding transaction/session completed.

## Learning
For real production blocking incidents, inspect `pg_stat_activity`, `pg_locks`, and blocker/waiter relationships. Advisory locks provided a deterministic way to demonstrate contention in this hosted lab.
