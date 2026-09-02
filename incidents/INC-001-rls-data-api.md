# INC-001 — RLS / Data API access failure

This is a self-directed simulated incident in a hosted Supabase project. It is not a production customer case.

## Incident metadata

- **Incident ID:** `INC-001`
- **Title:** Data API returned no rows although rows existed
- **Status:** Resolved in the lab
- **Severity:** Provisional S2 / moderate customer impact
- **Priority:** P2 while scope was being confirmed
- **Affected area:** Supabase Data API / PostgREST / PostgreSQL RLS
- **Customer impact:** A customer using the REST Data API could not see support-ticket records that existed in the database. The initial scope was one table and was not assumed to represent data loss.
- **Detection or report:** Simulated customer report that the API returned an empty result.

## Customer symptom

The customer reported that a request for `support_tickets` succeeded but returned an empty array instead of the records they expected.

The important distinction was that the API response looked like “no matching rows,” not an explicit database error. That could be mistaken for deleted data, a filter problem, a wrong project, or an authorization issue.

## Initial assessment

- **What is confirmed:** The table contained four rows when checked through the SQL Editor, the Data API returned `[]`, and RLS was enabled on `public.support_tickets`.
- **What is not yet confirmed:** The intended access model, the full customer scope, whether other tables or users were affected, and whether the request was authenticated.
- **Initial assumptions:** The API request was using the `anon` role and the customer expected those rows to be readable through the Data API. These assumptions required verification before changing a policy.
- **Immediate safety concern:** Do not make customer data public merely to make the response non-empty. Confirm whether access should be anonymous, authenticated, or tenant-scoped.
- **First customer update:** Acknowledge the missing records, explain that an empty API response does not by itself prove data loss, and provide the next update after checking the request role, table, filters, and RLS configuration.

## Triage and prioritization

- **Why this priority was selected:** Data visibility is customer-impacting and could indicate either an availability problem or an authorization regression. It was treated as P2 provisionally until scope and security impact were known.
- **Who or what may be affected:** Users calling the affected Data API resource. The scope had to be checked rather than inferred from one empty response.
- **What I would investigate first:** Confirm the project and endpoint, remove accidental filter confusion, compare SQL visibility with API visibility, identify the request role, and inspect RLS policies.
- **What I would defer:** Schema changes, data restoration, disabling RLS, and broad public-read policies until the intended authorization model was confirmed.
- **Escalation trigger:** Escalate if multiple customers or tables are affected, if unauthorized data is exposed, if the policy changed unexpectedly, or if the issue cannot be explained by the request and policy configuration.

## Investigation

1. **Check:** Query `public.support_tickets` through the SQL Editor.
   - **Reason:** Establish whether the records exist before treating the symptom as data loss.
   - **Result:** Four rows existed.
2. **Check:** Repeat the Data API request without changing the database.
   - **Reason:** Confirm the customer-facing failure and distinguish it from a one-off client problem.
   - **Result:** The request returned `[]`.
3. **Check:** Confirm the target project, table, selected columns, filters, and request role.
   - **Reason:** An empty result can come from a wrong endpoint, filter, project, or authorization context.
   - **Result:** The request targeted the expected table and used the anonymous role.
4. **Check:** Inspect RLS state and applicable `SELECT` policies.
   - **Reason:** Data API queries are evaluated under the request role and can return no visible rows when RLS has no matching policy.
   - **Result:** RLS was enabled and no `SELECT` policy allowed the `anon` role to read the rows.

## Evidence

- SQL query confirmed four rows existed in `public.support_tickets`.
- The same Data API request returned an empty JSON array.
- RLS was enabled on `public.support_tickets`.
- No matching `anon` `SELECT` policy existed before the lab recovery step.
- The repository seed and policy statements are in [`sql/schema.sql`](../sql/schema.sql), [`sql/seed.sql`](../sql/seed.sql), and [`sql/rls-policies.sql`](../sql/rls-policies.sql).
- **Evidence limitation:** This lab does not establish a real customer scope, production timeline, or business SLA. Those details must not be invented.

## Root cause

- **Root cause:** RLS was enabled on `public.support_tickets`, but no `SELECT` policy allowed the anonymous request role to read rows.
- **Contributing factors:** SQL Editor visibility and Data API visibility were checked through different authorization contexts, making the symptom look like missing data.
- **Why the initial symptom could be misleading:** PostgREST can return an empty result when rows exist but the effective role is not authorized to see them. Empty output is not proof that rows were deleted.

## Remediation

- **Fix applied in the lab:** A temporary public-read policy was created for the anonymous role, and the original request then returned the four expected rows.

  ```sql
  create policy "allow public read for support lab"
  on public.support_tickets
  for select
  to anon
  using (true);
  ```

- **Why this is the smallest lab fix:** It changed only the missing `SELECT` authorization rule and did not alter the table or data.
- **Security or data risks considered:** `using (true)` exposes every row to anonymous callers. That is not a safe default for real customer or tenant data.
- **Production recommendation:** Confirm the intended access model first. For private data, prefer authenticated and appropriately tenant-scoped policies; do not copy this public policy into production without an explicit security decision.
- **Rollback or recovery plan:** Drop the temporary policy if public access is not intended, then add and test the correct authenticated or tenant-scoped policy.
- **Lab-only limitation:** The anonymous policy exists to demonstrate the RLS failure and recovery path. It is not presented as a production design.

## Customer-facing response

> **Subject:** Update on the empty `support_tickets` API response
>
> Hi [customer],
>
> **What we found:** The records are still present in the database. The empty API response was caused by the request being evaluated as an anonymous user while Row Level Security did not contain a policy allowing that role to read the table. This is an access-control issue, not evidence that the records were deleted.
>
> **What we need to confirm:** Before changing access, we need to confirm whether these records are intended to be public or available only to authenticated users or a specific tenant. Making the table publicly readable would be an unsafe workaround for private data.
>
> **Next step:** Once the intended access model is confirmed, we will apply the narrowest matching policy and retest the same API request using the correct authorization context.
>
> **How we will verify the fix:** We will confirm that the intended user can read the expected records, that an unauthorized user cannot read them, and that the API response matches the database state.
>
> I will provide the next update after the access model and policy scope are confirmed.
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Not for the isolated lab reproduction; escalate in production if scope is broad, policy changes are unexpected, or unauthorized exposure is detected.
- **Team or owner:** Supabase support/application owner, with security or database engineering involved if policy scope is unclear.
- **Technical summary:** Four rows existed in PostgreSQL, while an anonymous Data API request returned `[]`. RLS was enabled and no matching anonymous `SELECT` policy existed.
- **Evidence attached:** SQL row-count result, original empty API response, RLS/policy inspection, and post-fix response.
- **Customer impact and urgency:** Expected records were not visible through the API; provisional P2 until scope was confirmed.
- **Specific question or decision needed:** Should this resource be public, authenticated-only, or restricted by tenant/user ownership?
- **Next owner and follow-up time:** Application owner to confirm authorization requirements; support to update the customer after the policy is tested.

## Recovery validation

- **Original failing test:** The same anonymous Data API request returned `[]`.
- **Post-fix result:** In the lab, the request returned the four expected rows after the temporary policy was added.
- **Authorization or security validation:** The lab recovery demonstrates public readability only. A production validation must also test that unauthorized users cannot read data.
- **Scope validation:** Confirmed for the seeded `support_tickets` table; broader customer scope was not established.
- **Monitoring or follow-up period:** Not applicable to this local lab reproduction; production would require monitoring and a follow-up check after the policy change.

## Prevention and learning

- Add an RLS test for the intended anonymous/authenticated/tenant access model before exposing a table through the Data API.
- Document the difference between SQL Editor visibility and Data API visibility under the effective request role.
- Add a runbook check for project, endpoint, filters, request role, RLS state, and matching policies before investigating data loss.
- Do not use a public `using (true)` policy as a generic fix for an empty API response.
- **Transferable lesson:** When the database contains rows but the API returns no rows, investigate authorization context and RLS before assuming deletion or corruption.
