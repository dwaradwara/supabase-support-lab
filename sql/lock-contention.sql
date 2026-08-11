-- INC-004: advisory lock contention

-- Session A
select pg_advisory_xact_lock(424242);
select pg_sleep(30);

-- Session B, while Session A holds the lock
select pg_try_advisory_xact_lock(424242);

-- Expected while held: false
-- Expected after Session A completes: true
