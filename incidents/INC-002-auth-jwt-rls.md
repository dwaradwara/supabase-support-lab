# INC-002 — Authentication, JWT and authenticated RLS

This is a self-directed simulated incident in a hosted Supabase project. It is not a production customer case.

## Incident metadata

- **Incident ID:** `INC-002`
- **Title:** Login and authenticated Data API access failed at separate layers
- **Status:** Resolved in the lab
- **Severity:** Provisional S2 / moderate access impact
- **Priority:** P2 while the failing request layer and customer scope were being confirmed
- **Affected area:** Supabase Auth / API key validation / JWT / PostgreSQL RLS
- **Customer impact:** A customer could not authenticate and could not retrieve protected ticket data through the Data API. The separate failures did not establish a platform-wide outage.
- **Detection or report:** Simulated report of login failure followed by missing protected records.

## Customer symptom

The customer reported that authentication was failing and that protected records were not visible through the API.

Several requests produced different errors. Treating them as one generic “authentication problem” would make the investigation slower and could lead to changing the wrong layer.

## Initial assessment

- **What is confirmed:** A malformed request body caused JSON parsing failure, an invalid project API key was rejected before login validation, and a valid request with the wrong password returned `invalid_credentials`.
- **What is not yet confirmed:** Whether the customer’s account exists, whether it is confirmed or otherwise restricted, whether the project key is current, whether the request includes the JWT, and whether the RLS policy matches the intended user scope.
- **Initial assumptions:** The customer is using the correct project and intends to access a protected resource as an authenticated user. These assumptions must be checked against the request and project configuration.
- **Immediate safety concern:** Never ask a customer to send a password, JWT, service key, or secret key in a ticket. Do not expose tokens in screenshots or logs.
- **First customer update:** Explain that the request is being separated into request format, project-key, credential, token, and authorization checks, and ask for a redacted request shape and timestamp rather than secrets.

## Triage and prioritization

- **Why this priority was selected:** The customer’s login and protected-data workflow was blocked, but the differing errors suggested a request or credential problem rather than a confirmed platform outage. It was treated as P2 provisionally.
- **Who or what may be affected:** The requesting user and potentially other users using the same client configuration. Scope must be tested with a safe test account.
- **What I would investigate first:** Request serialization, project URL/key, Auth response, user state, JWT presence/expiry, effective role, and RLS behavior.
- **What I would defer:** Disabling RLS, switching to a service key, changing password policy, or changing database policies before the failing layer is identified.
- **Escalation trigger:** Escalate if multiple users cannot authenticate, tokens are issued incorrectly, a key appears compromised, Auth is unavailable, or authenticated users are broadly denied despite a correct policy.

## Investigation

1. **Check:** Validate the request body before sending it.
   - **Reason:** A malformed body can fail before Auth evaluates credentials.
   - **Result:** The malformed request produced a JSON parsing error in Auth logs.
2. **Check:** Validate the project URL and publishable key independently.
   - **Reason:** A bad project key can be rejected before user credentials are checked.
   - **Result:** The invalid key request was rejected before login validation.
3. **Check:** Retry with valid JSON and the correct project key, then inspect only the redacted Auth result.
   - **Reason:** Isolate user credentials from request and project configuration.
   - **Result:** The wrong-password request returned `invalid_credentials`.
4. **Check:** Retry with the correct test-user credentials.
   - **Reason:** Confirm whether Auth can issue a session for the intended user.
   - **Result:** Login returned a valid access token; the token was not stored in the repository or screenshots.
5. **Check:** Call the protected Data API resource with and without the JWT.
   - **Reason:** Prove the difference between authentication and authenticated authorization.
   - **Result:** The authenticated request returned four tickets; the same request without the JWT returned zero rows under the authenticated-only RLS policy.

## Evidence

- Auth logs showed JSON parsing failure for the malformed body.
- The invalid project key was rejected before login validation.
- The valid request with the wrong password returned `invalid_credentials`.
- Successful login returned a valid access token with a reported 3600-second expiry.
- The authenticated Data API request returned four tickets.
- The same request without the JWT returned zero rows.
- The authenticated-only policy is in [`sql/rls-policies.sql`](../sql/rls-policies.sql).
- **Evidence limitation:** The repository does not store raw tokens, passwords, full API keys, or a current end-user transcript. The evidence demonstrates layer separation in the lab, not production Auth availability or customer scope.

## Root cause

- **Root cause:** There was no single root cause. Separate failures occurred at request serialization, project API-key validation, user credential validation, and then authenticated authorization.
- **Contributing factors:** The errors were initially easy to group under “authentication,” even though they occurred before and after credential verification at different layers.
- **Why the initial symptom could be misleading:** A user can authenticate successfully and still see no Data API rows if the request lacks the JWT or the RLS policy does not permit the authenticated role.

## Remediation

- **Fix applied in the lab:** Serialize the request body correctly, use the correct publishable key variable, use the correct test-user credentials, and replace the temporary anonymous read policy with an authenticated-only policy.

  ```sql
  create policy "authenticated users can read tickets"
  on public.support_tickets
  for select
  to authenticated
  using (true);
  ```

- **Why this is the smallest safe fix:** Each change addressed the layer that actually failed; no RLS bypass or service key was introduced.
- **Security or data risks considered:** `using (true)` allows every authenticated user to read every row in this lab. A real application should use ownership or tenant conditions and least-privilege grants.
- **Rollback or recovery plan:** Revert only the incorrect request/configuration change, or replace the lab-wide policy with the intended scoped policy after confirming the access model.
- **Credential handling:** Keep passwords, access tokens, secret keys, and full API keys out of source files, screenshots, tickets, and chat.
- **Lab-only limitation:** The test-user and policy are for a controlled simulation and are not evidence of production Auth operations.

## Customer-facing response

> **Subject:** Update on the login and protected-data access errors
>
> Hi [customer],
>
> **What we found:** The requests were failing at different layers. One request was not valid JSON, another used an invalid project key, and a later request reached credential validation but used invalid credentials. These are separate from the authorization check that controls access to protected records.
>
> **What to check:** Please confirm that the request body is valid JSON, that the request targets the intended project, and that the client uses the public publishable key. Please do not send us your password, access token, or secret key.
>
> **After login:** The authenticated session must be included when requesting protected records. A successful login alone does not grant access if the API request does not carry the user’s session or if the policy does not match the intended user scope.
>
> **How we will verify the fix:** We will confirm successful login without exposing the token, verify its presence and expiry, repeat the protected request with the authenticated session, and confirm that an unauthenticated request remains denied.
>
> I will provide the next update after the request and authorization checks are complete.
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Not for the isolated lab reproduction; escalate if failures affect multiple users, Auth availability is suspected, or a key/token may be compromised.
- **Team or owner:** Auth/application owner for login and client configuration; database/security owner for RLS scope.
- **Technical summary:** Four request layers were isolated: malformed JSON, invalid project key, invalid credentials, and authenticated Data API authorization. Successful login plus a JWT returned four tickets; the same request without the JWT returned zero rows.
- **Evidence attached:** Redacted Auth responses, token-expiry observation without the token, authenticated/unauthenticated API results, and the RLS policy.
- **Customer impact and urgency:** Login and protected-data workflow blocked in the simulation; production scope and SLA effect were not measured.
- **Specific question or decision needed:** Is the protected resource intended for every authenticated user or only the owning user/tenant?
- **Next owner and follow-up time:** Application/Auth owner to confirm client configuration; database owner to confirm policy scope; support to update the customer.

## Recovery validation

- **Original failing tests:** Malformed JSON failed parsing; invalid key failed before login validation; wrong password returned `invalid_credentials`; protected API access without a JWT returned zero rows.
- **Post-fix result:** Correct login returned a valid token with 3600-second expiry, and the authenticated request returned four tickets.
- **Authorization or security validation:** The authenticated-only policy allowed the authenticated test request while the request without the JWT remained unable to see rows.
- **Scope validation:** Confirmed for the seeded table and test user; tenant/owner isolation was not implemented in this lab.
- **Monitoring or follow-up period:** Not applicable to the lab; production would monitor Auth errors, token failures, API authorization errors, and policy changes.

## Prevention and learning

- Validate request serialization before investigating credentials.
- Check project key, user credentials, JWT issuance, and RLS as separate layers.
- Add redacted Auth/API diagnostics that preserve timestamps and status without secrets.
- Test both authenticated success and unauthenticated denial for protected resources.
- Replace broad authenticated policies with user- or tenant-scoped policies in real applications.
- **Transferable lesson:** Separate request validity, project access, authentication, token propagation, and authorization before changing configuration or escalating a platform outage.
