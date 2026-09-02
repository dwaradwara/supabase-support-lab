# Redacted request/response examples

These examples are taken from the lab’s observed test patterns and intentionally remove project keys, tokens, passwords, customer data, and credential-bearing connection details.

## Auth login

```http
POST https://<project-ref>.supabase.co/auth/v1/token?grant_type=password
apikey: <publishable-key-redacted>
Content-Type: application/json

{"email":"<test-user-redacted>","password":"<not-recorded>"}
```

Observed wrong-password response:

```json
{"error":"invalid_grant","error_description":"Invalid login credentials"}
```

Interpretation: the request reached Auth and credentials were rejected. This is not evidence of an RLS failure.

## Data API without a JWT

```http
GET https://<project-ref>.supabase.co/rest/v1/support_tickets?select=*
apikey: <publishable-key-redacted>
```

Observed result: HTTP 200 with an empty array while the SQL Editor showed four rows.

Interpretation: database visibility and request-role visibility differed; the next check was the table’s RLS policy for the effective anonymous role.

## Storage anonymous upload

```text
Operation: upload harmless validation file
Bucket: support-evidence
Object path: inc-006-client-test-<timestamp>-INC-006-upload-validation.txt
Authorization: no end-user session
```

Observed result: HTTP 403, `new row violates row-level security policy`.

Interpretation: the private bucket correctly rejected the anonymous insert under the tested policy boundary.

## Storage authenticated upload

```text
Operation: same upload flow
Bucket: support-evidence
Object path: inc-006-client-test-<timestamp>-INC-006-upload-validation.txt
Authorization: authenticated test user session
```

Observed result: upload succeeded through the authenticated insert policy.

Interpretation: the tested project, session role, bucket, and insert path worked together. This does not prove every customer path or file type works.

## Performance evidence

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, customer_email, status
FROM support_tickets
WHERE customer_email = '<redacted-email>';
```

Observed before: sequential scan, 50,003 rows removed by the filter, 703 shared buffer hits.

Observed after the targeted B-tree index: index condition, 4 shared buffer hits, captured execution time 0.128 ms.

Interpretation: the plan improved for the tested lookup. The lab does not claim a measured production customer-latency reduction.
