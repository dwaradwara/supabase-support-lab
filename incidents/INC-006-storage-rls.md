# INC-006 — Supabase Storage RLS upload failure

This is a self-directed simulated incident in a hosted Supabase project. It is not a production customer case.

## Incident metadata

- **Incident ID:** `INC-006`
- **Title:** Authenticated upload denied for a private Storage bucket
- **Status:** Reproduced and resolved in the current hosted project
- **Severity:** Provisional S2 / moderate customer impact
- **Priority:** P2 while request scope and authorization state were being confirmed
- **Affected area:** Supabase Storage / `storage.objects` RLS / authentication
- **Customer impact:** A user could not upload a file to the private `support-evidence` bucket. The failure blocked a support-evidence workflow but did not establish data loss.
- **Detection or report:** Simulated customer report of a failed file upload.

## Customer symptom

Uploading a file to the private Storage bucket failed with an authorization error rather than a missing-bucket or network error.

The observed error included:

- `AccessDenied`
- `new row violates row-level security policy`

## Initial assessment

- **What is confirmed:** The bucket existed, the request reached Storage, and the unauthenticated upload was denied by authorization.
- **What is not yet confirmed:** Whether the customer intended an anonymous or authenticated upload, whether the JWT was valid and current, the object path, whether the request used overwrite/upsert, and whether the failure affected one user or all users.
- **Initial assumptions:** The intended workflow required an authenticated user uploading into `support-evidence`. The request role and token still had to be verified rather than assumed.
- **Immediate safety concern:** Do not make a private bucket public or bypass RLS with a service key in a client application just to make uploads succeed.
- **First customer update:** Confirm that the upload is being investigated as an access-control issue, ask for the request status/error and object path, and explain that bucket privacy will be preserved while the policy and authentication context are checked.

## Triage and prioritization

- **Why this priority was selected:** The customer workflow was blocked, but the evidence did not indicate data loss or unauthorized exposure. It was treated as P2 provisionally.
- **Who or what may be affected:** Users uploading to the affected bucket and any application path using the same policy. Scope must be tested rather than inferred from one request.
- **What I would investigate first:** Bucket privacy, HTTP status and error body, JWT presence and role, exact bucket/path, and the `storage.objects` policies for the relevant operation.
- **What I would defer:** Making the bucket public, using a service key from an untrusted client, broad policies without a bucket condition, and changing unrelated Storage metadata.
- **Escalation trigger:** Escalate if authenticated users are broadly blocked, unauthorized users can upload or access objects, the policy changed unexpectedly, or the issue appears across multiple buckets or projects.

## Investigation

1. **Check:** Confirm the bucket exists and is private.
   - **Reason:** Separate bucket configuration from request authorization.
   - **Result:** The bucket existed and the request targeted a private bucket.
2. **Check:** Capture the HTTP status, error body, bucket ID, object path, and request operation.
   - **Reason:** Distinguish authorization failure from an invalid path, file restriction, network issue, or overwrite behavior.
   - **Result:** The response included `AccessDenied` and a row-level-security violation.
3. **Check:** Verify the request role and JWT.
   - **Reason:** `anon` and `authenticated` are different Postgres roles, and a policy for one does not authorize the other.
   - **Result:** The initial failing request was unauthenticated; the authenticated retry used a valid user JWT.
4. **Check:** Inspect `storage.objects` policies for `INSERT` and the bucket condition.
   - **Reason:** Storage upload permission is controlled through RLS on the object metadata table and should be scoped to the required bucket.
   - **Result:** No matching `INSERT` policy allowed the original request.
5. **Check:** Re-run the authenticated upload and confirm whether Storage can return the created object metadata.
   - **Reason:** Some Storage upload flows use `RETURNING` behavior; current Supabase troubleshooting guidance says a matching `SELECT` policy may also be needed for the upload response to succeed.
   - **Result in the original lab run:** The authenticated retry returned HTTP 200 and created the object.
   - **Current project result:** The local client signed in with a valid Auth user and the upload succeeded through the `authenticated` policy.

## Evidence

- The bucket existed and the request reached Storage.
- The unauthenticated request produced `AccessDenied` and `new row violates row-level security policy`.
- The original lab evidence records an authenticated retry returning HTTP 200 and creating an object.
- The policy used in the original lab is in [`sql/rls-policies.sql`](../sql/rls-policies.sql).
- The failure screenshot is [`evidence/screenshots/INC-006-storage-rls-failure.png`](../evidence/screenshots/INC-006-storage-rls-failure.png).
- The 2026-09-02 dashboard validation is recorded in [`evidence/INC-006-validation-2026-09-02.md`](../evidence/INC-006-validation-2026-09-02.md).
- **Evidence limitation:** The repository does not include a screenshot of the client response or a raw HTTP transcript. The validation record captures the observed status and object paths without storing credentials or JWTs.

## Root cause

- **Root cause observed in the original lab:** No `INSERT` policy on `storage.objects` matched the upload request for the required bucket and role.
- **Contributing factors:** The initial request was unauthenticated, while the intended recovery path required an authenticated user JWT. Bucket existence alone does not grant upload permission.
- **Important validation caveat:** Depending on the Storage operation and response behavior, the service may also need a matching `SELECT` policy to return the newly created object metadata. An `INSERT`-only policy must not be assumed sufficient without testing the exact upload flow.

## Remediation

- **Fix applied in the original lab:** An authenticated, bucket-scoped `INSERT` policy was created:

  ```sql
  create policy "authenticated users upload support evidence"
  on storage.objects
  for insert
  to authenticated
  with check (
      bucket_id = 'support-evidence'
  );
  ```

- **Why this is the smallest intended fix:** It grants only authenticated users permission to insert objects in the required bucket rather than making the bucket public.
- **Security or data risks considered:** The policy is bucket-scoped but does not restrict paths, file types, ownership, or quotas. Those controls may be required for a real application.
- **Additional validation:** The exact local client upload was re-run successfully. This flow returned the object path without requiring an additional `SELECT` policy. Other upload modes, including overwrite/upsert, should be tested separately if they are part of the application.
- **Rollback or recovery plan:** Remove the policy if the access model is wrong, then replace it with a policy scoped to the correct user, tenant, folder, or operation.
- **Unsafe workaround rejected:** Do not expose the bucket publicly or place a service key in browser/client code.

## Customer-facing response

> **Subject:** Update on the failed upload to `support-evidence`
>
> Hi [customer],
>
> **What we found:** The bucket exists and the request reached Storage, but the upload was rejected by the access policy. The failing request was evaluated without the authenticated user context required by the current upload policy.
>
> **What to check:** Please confirm that the user is signed in, that the request includes the current user session, and that the upload targets the intended `support-evidence` bucket and path. Please do not add a service key to client-side code or make the private bucket public as a workaround.
>
> **What we will verify:** We will retry the same upload with a valid authenticated session, confirm the bucket-scoped policy, and verify that the object is created without granting unrelated users access.
>
> **How to validate the fix:** The intended authenticated user should receive a successful upload response and be able to use the resulting object according to the application’s access rules. An unauthenticated request should remain denied.
>
> I will provide the next update after the authenticated retry and access-scope checks are complete.
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Not for the isolated lab reproduction; escalate if authenticated users remain blocked or if the policy permits unintended users or paths.
- **Team or owner:** Supabase support/application owner; involve security or application engineering if ownership or path isolation is required.
- **Technical summary:** A private bucket upload reached Storage but failed with an RLS violation. The initial request was unauthenticated and no matching bucket-scoped `INSERT` policy existed.
- **Evidence attached:** Error response, bucket configuration, JWT role, policy inspection, failed upload, and successful retry.
- **Customer impact and urgency:** Upload workflow blocked for the affected request; provisional P2.
- **Specific question or decision needed:** Should all authenticated users upload to this bucket, or must uploads be restricted by user, tenant, or folder?
- **Next owner and follow-up time:** Application owner to confirm the access model; support to retest and update the customer.

## Recovery validation

- **Original failing test:** Unauthenticated upload to the private bucket returned an authorization/RLS error.
- **Post-fix result in the original lab:** Authenticated upload returned HTTP 200 and the object was created.
- **Current verification result:** The client sign-in succeeded and the upload returned an object path. No additional `SELECT` policy was needed for this exact flow.
- **Authorization or security validation:** Unauthenticated upload must remain denied; an authenticated user must be allowed only within the intended bucket/path scope.
- **Scope validation:** Confirm that the policy does not unintentionally authorize other buckets or unrelated paths.
- **Monitoring or follow-up period:** Not applicable to the original lab run; a production workflow would monitor failed uploads and policy changes.

## Prevention and learning

- Add a Storage access test for unauthenticated denial and authenticated success.
- Test the exact upload response path, including any metadata read-back requirement.
- Scope policies to bucket, user, tenant, or folder as the application requires.
- Document the difference between bucket privacy and object-operation policies.
- Keep service keys server-side only.
- **Transferable lesson:** When a Storage upload fails, verify bucket configuration, request role, JWT, operation, object path, and `storage.objects` policies before changing visibility or credentials.
