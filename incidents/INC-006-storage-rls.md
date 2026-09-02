# INC-006 - Supabase Storage RLS upload failure

## Simulated customer ticket

> Uploading evidence to a private Storage bucket fails, although the bucket
> exists and is visible in the dashboard.

## Evidence

The captured response showed two different status representations:

- transport status line: `HTTP/1.1 400 Bad Request`
- JSON payload: `statusCode: "403"`, `error: "Unauthorized"`,
  `code: "AccessDenied"`
- message: `new row violates row-level security policy`

The incident must not be summarized only as "HTTP 403" because the captured
HTTP status line was 400 while the payload reported authorization status 403.

## Investigation

- Bucket existed.
- Request reached Storage.
- Upload attempted to create a row in `storage.objects`.
- No matching INSERT policy allowed the request context.

## Original root cause

No INSERT policy on `storage.objects` allowed the upload.

## Version 2 security correction

The original bucket-only policy allowed every authenticated user to upload to
any object path in the bucket. Version 2 scopes each upload to a user-owned
folder:

```text
support-evidence/<auth.uid()>/<filename>
```

See `sql/rls-policies.sql`.

## Validation requirements

- User uploads inside their own folder.
- The same user cannot upload inside another user's folder.
- Anonymous upload fails.
- Upload to another bucket fails.
- The object exists after the successful upload.
- Evidence records the transport status and payload separately.

Actual Version 2 API output is pending execution against the hosted lab project.

## Customer-facing resolution

The bucket existed, but bucket creation alone does not grant object access.
Storage attempted to insert object metadata and PostgreSQL RLS rejected it. We
added a policy limited to the authenticated user's folder, then tested both the
allowed upload and cross-user denial. The bucket remains private.
