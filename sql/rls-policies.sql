-- RLS policies used during the lab

-- INC-001 recovery policy (used temporarily)
create policy "allow public read for support lab"
on public.support_tickets
for select
to anon
using (true);

-- INC-002 authenticated-only access
drop policy if exists "allow public read for support lab"
on public.support_tickets;

create policy "authenticated users can read tickets"
on public.support_tickets
for select
to authenticated
using (true);

-- INC-006 authenticated Storage upload policy
create policy "authenticated users upload support evidence"
on storage.objects
for insert
to authenticated
with check (
    bucket_id = 'support-evidence'
);
