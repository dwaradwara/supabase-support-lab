-- DESTRUCTIVE: lab-only reset.
-- Never run this against a production project or any database containing data
-- that must be retained.

drop table if exists public.ticket_updates cascade;
drop table if exists public.support_tickets cascade;

-- Storage objects are not deleted here. Remove lab objects through the Storage
-- API or dashboard before deleting a bucket so object metadata stays consistent.
