-- Initial support data

insert into public.support_tickets
(customer_email, subject, status, priority)
values
('alice@example.com', 'API returns 500', 'open', 'high'),
('bob@example.com', 'Cannot login', 'open', 'high'),
('charlie@example.com', 'Dashboard loading slowly', 'investigating', 'medium'),
('david@example.com', 'File upload failed', 'open', 'low');

insert into public.ticket_updates
(ticket_id, update_text)
values
(1, 'Customer reports HTTP 500 from API'),
(1, 'Initial investigation started'),
(2, 'Customer unable to authenticate'),
(3, 'Checking database query performance');

-- Performance dataset used in INC-003
insert into public.support_tickets
(customer_email, subject, status, priority)
select
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
