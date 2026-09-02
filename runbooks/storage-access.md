# Runbook - Supabase Storage access

1. Confirm the bucket and whether it is public or private.
2. Capture the actual HTTP status line and JSON error fields separately.
3. Confirm the object path and operation: INSERT, SELECT, UPDATE or DELETE.
4. Check the request role/JWT without logging the full token.
5. Review the matching RLS policy on `storage.objects`.
6. Scope access to the required bucket and, where appropriate, a user/team path.
7. Retry the exact upload with the intended identity.
8. Perform a negative test against another user's path and another bucket.
9. Confirm the resulting object exists and remains private when required.
10. Do not make a private bucket public merely to bypass a policy failure.
