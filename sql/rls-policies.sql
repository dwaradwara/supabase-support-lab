-- Secure final-state RLS policies used by the lab.

drop policy if exists "allow public read for support lab"
on public.support_tickets;

drop policy if exists "authenticated users can read tickets"
on public.support_tickets;

drop policy if exists "users read their own tickets"
on public.support_tickets;

create policy "users read their own tickets"
on public.support_tickets
for select
to authenticated
using ((select auth.uid()) = owner_id);

drop policy if exists "users read updates for their tickets"
on public.ticket_updates;

create policy "users read updates for their tickets"
on public.ticket_updates
for select
to authenticated
using (
    exists (
        select 1
        from public.support_tickets as ticket
        where ticket.id = ticket_updates.ticket_id
          and ticket.owner_id = (select auth.uid())
    )
);

drop policy if exists "authenticated users upload support evidence"
on storage.objects;

drop policy if exists "users upload evidence to their folder"
on storage.objects;

create policy "users upload evidence to their folder"
on storage.objects
for insert
to authenticated
with check (
    bucket_id = 'support-evidence'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
);
