-- Deterministic synthetic data for the Supabase Support Lab.
-- Run sql/00-reset.sql and sql/schema.sql before this file.

-- Synthetic identities used by sql/rls-validation.sql.
-- User A: 00000000-0000-0000-0000-000000000001
-- User B: 00000000-0000-0000-0000-000000000002

insert into public.support_tickets
(owner_id, customer_email, subject, status, priority)
values
('00000000-0000-0000-0000-000000000001', 'alice@example.com', 'API returns 500', 'open', 'high'),
('00000000-0000-0000-0000-000000000002', 'bob@example.com', 'Cannot login', 'open', 'high'),
('00000000-0000-0000-0000-000000000001', 'charlie@example.com', 'Dashboard loading slowly', 'investigating', 'medium'),
('00000000-0000-0000-0000-000000000002', 'david@example.com', 'File upload failed', 'open', 'low');

insert into public.ticket_updates
(ticket_id, update_text)
values
(1, 'Customer reports HTTP 500 from API'),
(1, 'Initial investigation started'),
(2, 'Customer unable to authenticate'),
(3, 'Checking database query performance');

-- Performance dataset used in INC-003. Ownership alternates between the two
-- synthetic identities so RLS isolation can be validated at realistic size.
insert into public.support_tickets
(owner_id, customer_email, subject, status, priority)
select
    case when g % 2 = 0
         then '00000000-0000-0000-0000-000000000001'::uuid
         else '00000000-0000-0000-0000-000000000002'::uuid
    end,
    'user' || g || '@example.com',
    'Generated support ticket ' || g,
    case
        when g % 3 = 0 then 'resolved'
        when g % 3 = 1 then 'open'
        else 'investigating'
    end,
    case
        when g % 4 = 0 then 'high'
        when g % 4 = 1 then 'medium'
        else 'low'
    end
from generate_series(1, 50000) as g;
