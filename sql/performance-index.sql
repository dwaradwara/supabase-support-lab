-- INC-003: PostgreSQL query performance

analyze public.support_tickets;

explain (analyze, buffers)
select *
from public.support_tickets
where customer_email = 'user42000@example.com';

create index if not exists idx_support_tickets_customer_email
on public.support_tickets(customer_email);

analyze public.support_tickets;

explain (analyze, buffers)
select *
from public.support_tickets
where customer_email = 'user42000@example.com';
