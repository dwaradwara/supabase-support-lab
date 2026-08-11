# Runbook — Supabase Storage access

1. Confirm the bucket exists and whether it is public/private.
2. Capture the Storage error body and HTTP status.
3. Check `storage.objects` RLS policies.
4. Confirm the request role and JWT are what the policy expects.
5. Scope policies to the required bucket rather than granting global access.
6. Retry the same upload/download and validate the resulting object.
