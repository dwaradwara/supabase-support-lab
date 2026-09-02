-- Manual positive and negative RLS validation.
-- Expected results are documented beside each query.
-- Run after schema.sql, seed.sql and rls-policies.sql.

-- Test 1: anonymous requests receive zero rows rather than all tickets.
begin;
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select count(*) as anonymous_visible_rows
from public.support_tickets;
-- Expected: 0
rollback;

-- Test 2: User A can see only rows owned by User A.
begin;
set local role authenticated;
select set_config(
    'request.jwt.claims',
    '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}',
    true
);
select
    count(*) as visible_rows,
    count(*) filter (
        where owner_id <> '00000000-0000-0000-0000-000000000001'::uuid
    ) as rows_owned_by_someone_else
from public.support_tickets;
-- Expected: visible_rows > 0 and rows_owned_by_someone_else = 0
rollback;

-- Test 3: User B can see only rows owned by User B.
begin;
set local role authenticated;
select set_config(
    'request.jwt.claims',
    '{"sub":"00000000-0000-0000-0000-000000000002","role":"authenticated"}',
    true
);
select
    count(*) as visible_rows,
    count(*) filter (
        where owner_id <> '00000000-0000-0000-0000-000000000002'::uuid
    ) as rows_owned_by_someone_else
from public.support_tickets;
-- Expected: visible_rows > 0 and rows_owned_by_someone_else = 0
rollback;

-- Test 4: a user with no owned tickets receives zero rows.
begin;
set local role authenticated;
select set_config(
    'request.jwt.claims',
    '{"sub":"00000000-0000-0000-0000-000000000099","role":"authenticated"}',
    true
);
select count(*) as unrelated_user_visible_rows
from public.support_tickets;
-- Expected: 0
rollback;
