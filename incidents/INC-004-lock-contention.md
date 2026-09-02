# INC-004 - PostgreSQL row-lock contention

## Simulated customer ticket

> A normally fast ticket update now hangs until it times out. Reads still work,
> and there was no application deployment.

## Impact and scope

One write path is blocked. Before treating this as query-performance regression,
the investigation must determine whether the query is waiting on another
transaction.

## Reproduction

`sql/lock-contention.sql` uses three sessions:

- Session A updates ticket 1 and leaves the transaction open.
- Session B attempts to update the same row and waits.
- Session C identifies the waiter and blocker.

## Evidence to capture

- blocked and blocking PIDs
- `wait_event_type` and `wait_event`
- blocked query and blocking query
- blocking transaction age
- relevant rows from `pg_locks`
- recovery after Session A rolls back

## Root cause

Session A retained a row lock because its transaction remained open. Session B
requested an incompatible lock on the same row and waited.

## Recovery

For this controlled lab, Session A rolls back, releasing the lock. Session B can
then complete. In production, do not terminate a backend automatically. Confirm
customer impact, transaction purpose, application owner, rollback risk and
whether a normal commit/rollback is available.

## Validation

- `pg_blocking_pids()` identifies Session A as the blocker.
- Session B has a lock-related wait event.
- Session B completes after Session A releases the lock.
- No unrelated backend is terminated.

Actual Version 2 output is pending execution against the hosted lab project.

## Prevention

- keep transactions short
- commit or roll back on every application path
- avoid user/network waits inside a transaction
- monitor long-running and `idle in transaction` sessions
- use consistent update order for workflows touching several rows

## Customer-facing resolution

The query itself had not become computationally slower. It was waiting for an
earlier transaction that still held a lock on the same ticket row. After the
older lab transaction was safely rolled back, the waiting update completed. The
recommended application fix is to ensure every transaction closes promptly and
does not remain open while waiting on external work.
