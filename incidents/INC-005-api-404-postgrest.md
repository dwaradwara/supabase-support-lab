# INC-005 — Data API 404 / PostgREST resource error

This is a self-directed simulated incident in a hosted Supabase project. It is not a production customer case.

## Incident metadata

- **Incident ID:** `INC-005`
- **Title:** REST request targeted a misspelled PostgREST resource
- **Status:** Resolved in the lab
- **Severity:** Provisional S3 / limited workflow impact
- **Priority:** P3 while request scope and endpoint correctness were being confirmed
- **Affected area:** Supabase Data API / PostgREST / API Gateway
- **Customer impact:** The affected API request returned HTTP 404 because the URL referenced a resource that did not exist. The request failure did not establish that the project or database was unavailable.
- **Detection or report:** Simulated customer report of a 404 response from a REST endpoint.

## Customer symptom

The customer reported that a REST request returned HTTP 404 when attempting to retrieve support tickets.

The failing path was:

`/rest/v1/support_ticketssss?select=*`

The repeated `s` characters were the important clue. The first task was to read the PostgREST response and confirm the request in logs, not to restart the project or investigate database performance.

## Initial assessment

- **What is confirmed:** The request returned HTTP 404 with PostgREST error `PGRST205`, and the response hint referenced `public.support_tickets`.
- **What is not yet confirmed:** Whether the customer copied the correct project URL, whether the intended resource was a table or view, whether the corrected request should return rows, and whether RLS would affect the result after routing was fixed.
- **Initial assumptions:** The intended resource was `public.support_tickets` and the customer was using the expected project. Both assumptions required verification.
- **Immediate safety concern:** Do not expose broad data or disable RLS just because a corrected endpoint returns an empty array. Routing and authorization are separate checks.
- **First customer update:** Confirm that the 404 request is being checked as a resource-path problem, ask for the redacted method/path and timestamp, and explain that an HTTP 404 alone does not indicate a platform outage.

## Triage and prioritization

- **Why this priority was selected:** The request failed, but the error was specific and limited to one endpoint. No broad outage, data loss, or unauthorized access was indicated. It was treated as P3 provisionally.
- **Who or what may be affected:** Clients using the incorrect endpoint. The scope should be checked for shared configuration or generated SDK code.
- **What I would investigate first:** HTTP method/status, exact path, response body, project URL, API Gateway log entry, and the expected exposed resource.
- **What I would defer:** Database restart, schema changes, RLS changes, key rotation, and broad platform escalation until the resource path is validated.
- **Escalation trigger:** Escalate if a correct endpoint returns unexpected 404s across clients, the resource disappeared unexpectedly, schema cache behavior is suspected after a valid change, or multiple resources are affected.

## Investigation

1. **Check:** Capture the HTTP status, method, path, response body, and timestamp.
   - **Reason:** The error code and request details often identify a client-side path problem immediately.
   - **Result:** The request returned HTTP 404 and `PGRST205`.
2. **Check:** Read the PostgREST message and hint.
   - **Reason:** Avoid treating every 404 as infrastructure failure.
   - **Result:** The hint suggested `public.support_tickets`, while the request used the misspelled `support_ticketssss` resource.
3. **Check:** Correlate the request in Supabase Unified Logs → API Gateway.
   - **Reason:** Confirm that the request reached the expected project and that the gateway recorded the same path and status.
   - **Result:** The API Gateway log showed a 404 GET for the failing path.
4. **Check:** Confirm the intended table/resource and its exposed schema.
   - **Reason:** A corrected path must refer to a resource that exists and is available through the Data API.
   - **Result:** The intended resource was `public.support_tickets`.
5. **Check:** Re-run the corrected request, then interpret its result separately from RLS.
   - **Reason:** Fixing routing does not guarantee that the caller is authorized to see rows.
   - **Result:** `/rest/v1/support_tickets?select=*` returned HTTP 200. In the lab, anonymous RLS restrictions meant the response could still be empty.

## Evidence

- Failing path: `/rest/v1/support_ticketssss?select=*`.
- Failing status: HTTP 404.
- PostgREST code: `PGRST205`.
- PostgREST hint referenced `public.support_tickets`.
- API Gateway logs showed a matching 404 GET request.
- Corrected path: `/rest/v1/support_tickets?select=*`.
- Corrected request returned HTTP 200.
- Evidence screenshots are [`INC-005-pgrst205-404.png`](../evidence/screenshots/INC-005-pgrst205-404.png) and [`INC-005-api-gateway-404.png`](../evidence/screenshots/INC-005-api-gateway-404.png).
- **Evidence limitation:** The lab does not establish customer request volume, production availability, or a measured business impact. The HTTP 200 recovery confirms routing recovery, not successful row visibility for every role.

## Root cause

- **Root cause:** The client requested the misspelled resource `support_ticketssss`, which PostgREST could not resolve.
- **Contributing factors:** The endpoint typo made the request look like a platform or database problem, and the corrected response could still be empty because RLS is a separate authorization layer.
- **Why the initial symptom could be misleading:** HTTP 404 identifies a resource/routing problem in this case; it does not automatically mean Supabase is down. A later empty 200 response would need an RLS or filter investigation instead.

## Remediation

- **Fix applied in the lab:** Correct the endpoint to:

  `/rest/v1/support_tickets?select=*`

- **Why this is the smallest safe fix:** It changes only the incorrect resource path and leaves the database, policies, and project configuration unchanged.
- **Security or data risks considered:** Do not solve an empty post-fix response by weakening RLS. Confirm the caller role and intended access separately.
- **Rollback or recovery plan:** Revert the client configuration only if the intended resource is different; then verify the correct table/view and schema exposure.
- **Client prevention:** Centralize endpoint/resource names or use generated client methods where appropriate to reduce hand-typed path errors.

## Customer-facing response

> **Subject:** Update on the REST API 404 response
>
> Hi [customer],
>
> **What we found:** The request reached the API, but the URL referenced `support_ticketssss`, which is not the expected `support_tickets` resource. PostgREST returned `PGRST205` and suggested the correct resource name.
>
> **What to change:** Update the request path to:
>
> `/rest/v1/support_tickets?select=*`
>
> Keep the project URL, HTTP method, and required public key unchanged unless separate evidence indicates a configuration problem.
>
> **How we verified it:** We correlated the original 404 in the API Gateway logs and repeated the request with the corrected path. The corrected request returned HTTP 200.
>
> **Important note:** A successful HTTP response does not by itself guarantee that rows will be visible. If the corrected response is empty, we will check filters and the caller’s RLS authorization separately.
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Not for the isolated lab reproduction; escalate if valid resources return 404s across clients or if the resource disappeared unexpectedly.
- **Team or owner:** Application owner for endpoint configuration; database owner only if the resource or schema exposure is genuinely missing.
- **Technical summary:** A GET to `support_ticketssss` returned HTTP 404/PGRST205. API Gateway confirmed the request. The intended `support_tickets` path returned HTTP 200 after correction.
- **Evidence attached:** PostgREST response, API Gateway correlation, corrected request result, and endpoint configuration change.
- **Customer impact and urgency:** One simulated API request failed; broader scope and SLA effect were not measured.
- **Specific question or decision needed:** Is the corrected resource the intended public API contract, and should the client use a generated SDK method to avoid path typos?
- **Next owner and follow-up time:** Application owner to deploy the corrected path; support to confirm the customer’s response and row-visibility behavior.

## Recovery validation

- **Original failing test:** GET `/rest/v1/support_ticketssss?select=*` returned HTTP 404/PGRST205.
- **Post-fix result:** GET `/rest/v1/support_tickets?select=*` returned HTTP 200.
- **Authorization validation:** Row visibility must be checked separately using the intended `anon` or `authenticated` role; the lab’s anonymous RLS restriction can produce an empty successful response.
- **Scope validation:** Confirmed for the intended resource and one request path; other clients and generated configurations were not tested.
- **Monitoring or follow-up period:** Not applicable to the lab; production would monitor 4xx rates and endpoint usage after deployment.

## Prevention and learning

- Capture the exact URL and response body before escalating an API 404.
- Read PostgREST error codes and hints instead of assuming platform failure.
- Correlate the request in API Gateway logs using method, path, status, and timestamp.
- Separate resource routing, API-key/JWT validation, filters, and RLS authorization.
- Add endpoint smoke tests for important client paths.
- **Transferable lesson:** A precise error message and one correlated log entry can resolve a routing problem faster and more safely than broad infrastructure changes.
