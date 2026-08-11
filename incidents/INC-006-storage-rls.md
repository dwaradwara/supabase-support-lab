# INC-006 — Supabase Storage RLS upload failure

## Symptom
Uploading a file to a private Storage bucket failed.

## Evidence
The unauthenticated upload produced a Storage authorization error:
- `AccessDenied`
- `new row violates row-level security policy`

## Investigation
The bucket existed and the request reached Storage, so the failure was authorization-related rather than a missing bucket or network issue.

## Root cause
No `INSERT` policy on `storage.objects` allowed the request.

## Fix

```sql
create policy "authenticated users upload support evidence"
on storage.objects
for insert
to authenticated
with check (
    bucket_id = 'support-evidence'
);
```

The upload was then retried with a valid user JWT in the `Authorization` header.

## Recovery validation
Authenticated upload returned HTTP 200 and the object was created in the private bucket.

## Evidence
- [RLS failure](../evidence/screenshots/INC-006-storage-rls-failure.png)

## Learning
Supabase Storage authorization is enforced through PostgreSQL RLS on `storage.objects`; bucket existence alone does not grant upload permission.
