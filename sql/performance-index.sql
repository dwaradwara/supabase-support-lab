-- INC-003: reproducible PostgreSQL query-performance comparison.
-- LAB ONLY: dropping an index can block or degrade production workloads.

drop index if exists public.idx_support_tickets_customer_email;
analyze public.support_tickets;

-- Capture this complete plan as the before evidence.
explain (analyze, buffers, settings)
select *
from public.support_tickets
where customer_email = 'user42000@example.com';

create index idx_support_tickets_customer_email
on public.support_tickets using btree (customer_email);

analyze public.support_tickets;

-- Capture this complete plan as the after evidence.
explain (analyze, buffers, settings)
select *
from public.support_tickets
where customer_email = 'user42000@example.com';

-- Interpretation notes:
-- 1. A sequential scan is not automatically wrong. It can be appropriate for a
--    small table or a query returning a large percentage of rows.
-- 2. The index is justified here because the equality predicate is selective
--    and represents a repeated lookup pattern.
-- 3. The read improvement must be weighed against index storage and additional
--    write maintenance.
-- 4. EXPLAIN ANALYZE executes the statement. Use it cautiously in production.
