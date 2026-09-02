# Take-home response — TKT-103 authenticated Storage uploads return 403

> **Simulation only:** This is a practice answer to the fictional queue ticket. It is not a real customer response, production incident, or SLA record.

## Customer-facing response

**Subject:** Update on authenticated uploads returning 403

Hi,

I understand that three authenticated users are receiving HTTP 403 when uploading PDFs to your private Storage bucket, while existing downloads continue to work. That means the immediate impact appears limited to creating new document objects; it does not currently indicate that existing documents are unavailable.

I’m investigating this as an authorization-path issue. I’ll compare the failing object path and operation with the authenticated user’s request role, the bucket configuration, and the Storage policies that govern inserts. I’ll also compare the result with an unauthenticated request so we can confirm whether the policy boundary is behaving as intended.

Please send the following, with customer data and credentials removed:

- UTC timestamp of one failed upload
- Redacted bucket and object path
- HTTP status and exact error message
- Client/library version and upload method
- Whether every folder and file type fails
- Any recent policy, bucket, client, or deployment change

Please do not send passwords, JWTs, service-role keys, publishable keys, or private document contents. I will not recommend making the bucket public or placing a service-role key in the client as a workaround, because that would weaken the intended access boundary.

I’ll provide the next update after the controlled comparison. If downloads of existing objects also begin failing, or if additional projects are affected, please reply immediately so we can raise the incident priority.

Regards,  
Technical Support

## Internal investigation record

### Initial assessment

- **Provisional severity:** S2 / High
- **Provisional priority:** P1
- **Reason:** Three authenticated users are blocked from creating new documents in a core workflow. Existing downloads reportedly work, so this is not yet a complete Storage outage.
- **Likely layer:** Storage authorization policy, request role, object path, or client behavior. This is a hypothesis, not a confirmed root cause.

### Safe investigation sequence

1. Confirm the project, bucket privacy, exact operation, object path shape, timestamps, and affected scope.
2. Reproduce with an unauthenticated request using a harmless file. Expected result: denial for a private bucket with an authenticated-only insert policy.
3. Sign in with an approved test user and repeat the same upload path. Expected result: success if the user receives the `authenticated` role and the insert policy matches.
4. Inspect the effective Storage policy action and target table without exposing credentials. Check whether the policy depends on a path or user-id convention.
5. Compare the customer’s path and operation with the policy condition. Check whether the client is using the intended project and current session rather than a stale or missing session.
6. Validate the original failing flow after the smallest policy or client correction. Test anonymous denial again to ensure the fix did not make the bucket public.

### Evidence interpretation

| Observation | What it supports | What it does not prove |
|---|---|---|
| HTTP 403 with an RLS-policy error | The request reached Storage and was rejected by a row-level policy | That the bucket should be made public or that the platform is unavailable |
| Existing downloads work | Read access may be configured separately from insert access | That uploads use the same policy or role |
| Anonymous upload is denied | The access boundary blocks unauthenticated creation | That authenticated users are correctly authorized |
| Authenticated upload succeeds with a controlled test user | The project, bucket, session role, and tested insert path can work together | That every customer path, folder, file type, or client release works |

### Provisional root-cause decision

Do not declare root cause until the customer path is compared with the policy and the original flow is reproduced. If the controlled authenticated upload succeeds but the customer path fails, the leading possibilities are a missing/stale session, wrong project configuration, path-specific policy condition, or client release difference. If controlled authenticated uploads also fail, escalate with the policy definition, role evidence, timestamps, and reproduction details.

### Remediation standard

Apply only the narrowest correction that matches the intended authorization model—for example, correcting the client session/project configuration or adjusting a narrowly scoped insert policy after confirming the required ownership rule. Preserve the private bucket and authenticated boundary. Do not disable RLS, use a service-role key in a browser/mobile client, or change the bucket to public merely to make the symptom disappear.

### Recovery validation

- Authenticated upload succeeds with the intended test role.
- Anonymous upload remains denied.
- Existing-object download behavior is unchanged.
- A path outside the intended ownership rule is denied, if ownership restrictions apply.
- The customer confirms the original client workflow succeeds.
- The final ticket records timestamps, policy change, client version, and rollback path without secrets.

### Escalation decision

Escalate to the Storage/Auth/RLS specialist if the controlled authenticated test fails after project, session, path, and policy checks; if existing reads also fail; if multiple projects are affected; or if the customer reports possible unauthorized access. Include redacted reproduction data and a specific question rather than forwarding credentials or private files.
