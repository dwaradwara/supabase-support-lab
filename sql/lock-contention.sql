-- INC-004: real row-lock contention with blocker/waiter diagnostics.
-- Use three separate SQL sessions. Do not run all sections as one batch.

-- SESSION A: acquire and retain a row lock.
begin;
select pg_backend_pid() as session_a_pid;
update public.support_tickets
set status = 'investigating'
where id = 1;
-- Leave this transaction open while running Session B and Session C.

-- SESSION B: this update waits for Session A.
begin;
select pg_backend_pid() as session_b_pid;
set local statement_timeout = '60s';
update public.support_tickets
set status = 'resolved'
where id = 1;
-- Do not cancel immediately; inspect the wait from Session C first.

-- SESSION C: identify blocked and blocking backends.
select
    blocked.pid as blocked_pid,
    blocked.usename as blocked_user,
    blocked.wait_event_type,
    blocked.wait_event,
    now() - blocked.query_start as wait_duration,
    blocked.query as blocked_query,
    blocker.pid as blocking_pid,
    blocker.usename as blocking_user,
    now() - blocker.xact_start as blocking_transaction_age,
    blocker.state as blocking_state,
    blocker.query as blocking_query
from pg_stat_activity as blocked
join pg_stat_activity as blocker
  on blocker.pid = any(pg_blocking_pids(blocked.pid))
where cardinality(pg_blocking_pids(blocked.pid)) > 0;

-- Optional lock-level evidence from Session C.
select
    pid,
    locktype,
    relation::regclass as relation,
    mode,
    granted,
    waitstart
from pg_locks
where pid in (
    select pid
    from pg_stat_activity
    where cardinality(pg_blocking_pids(pid)) > 0
       or pid = any(
           select unnest(pg_blocking_pids(waiter.pid))
           from pg_stat_activity as waiter
       )
)
order by pid, granted;

-- RECOVERY: return to Session A and release the lock safely.
rollback;

-- Session B should then complete. Commit or roll back Session B after verifying
-- the result. Do not terminate a backend merely because it appears in this query.
