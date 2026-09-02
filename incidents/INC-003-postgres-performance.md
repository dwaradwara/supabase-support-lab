# INC-003 — PostgreSQL slow lookup / missing index

This is a self-directed simulated incident in a hosted Supabase project. It is not a production customer case.

## Incident metadata

- **Incident ID:** `INC-003`
- **Title:** Single-ticket lookup used a sequential scan
- **Status:** Resolved in the lab
- **Severity:** Provisional S2 / moderate performance impact
- **Priority:** P2 while affected query scope and workload impact were being confirmed
- **Affected area:** PostgreSQL query planning and indexing
- **Customer impact:** A lookup by `customer_email` scanned almost the entire `support_tickets` table. The lab demonstrates inefficient database work under the seeded dataset; it does not establish a production SLA breach or a measured customer latency regression.
- **Detection or report:** Simulated report that retrieving one support ticket had become slow.

## Customer symptom

The customer reported that a lookup for one support ticket by `customer_email` was slow, even though the query returned the expected record.

The first question is whether the delay is in PostgreSQL or elsewhere in the request path. A slow-looking request should not immediately lead to adding an index without checking the actual execution plan and workload.

## Initial assessment

- **What is confirmed:** The query used a sequential scan, removed 50,003 rows by its filter, and recorded 703 shared buffer hits in the lab.
- **What is not yet confirmed:** Production latency, query frequency, concurrency, customer scope, table growth rate, write workload, and whether the application has other filters or sort requirements.
- **Initial assumptions:** `customer_email` is a common lookup predicate and the table is large enough for an index to be worth evaluating. These assumptions require workload and selectivity checks in production.
- **Immediate safety concern:** Do not create indexes blindly on a production table. Indexes consume storage, add write and maintenance cost, and may not help a low-selectivity query.
- **First customer update:** Acknowledge the slow lookup, explain that the database execution plan is being checked, and provide a time-bounded update after the query path and scope are confirmed.

## Triage and prioritization

- **Why this priority was selected:** The query still returned data and no outage or data-integrity issue was established. It was treated as P2 provisionally, with priority increasing if many customers or critical workflows were affected.
- **Who or what may be affected:** Requests using this lookup predicate, especially as the table grows or concurrency increases. Scope must be measured rather than inferred from one query.
- **What I would investigate first:** Reproduce the exact query, capture `EXPLAIN (ANALYZE, BUFFERS)`, verify statistics, check query frequency and lock/wait conditions, and compare the plan with relevant indexes.
- **What I would defer:** Changing planner settings, rewriting unrelated application code, adding several speculative indexes, or claiming a latency improvement without a before/after measurement.
- **Escalation trigger:** Escalate if the issue affects a critical paid workflow, causes timeouts or errors, appears across multiple queries, or requires a high-risk online schema change.

## Investigation

1. **Check:** Reproduce the exact lookup for `user42000@example.com`.
   - **Reason:** Ensure the support investigation matches the customer’s request and data shape.
   - **Result:** The query returned the expected row but scanned nearly the full table.
2. **Check:** Run `EXPLAIN (ANALYZE, BUFFERS)` before changing the schema.
   - **Reason:** Identify the actual access path and distinguish database work from application or network delay.
   - **Result:** PostgreSQL used a sequential scan, removed 50,003 rows by filter, and recorded 703 shared buffer hits.
3. **Check:** Confirm the predicate, table statistics, existing indexes, and approximate selectivity.
   - **Reason:** An index should support the real predicate and workload, and statistics must be current enough for the planner.
   - **Result:** The query filtered on `customer_email`, no supporting index existed, and `ANALYZE` was run before the comparison.
4. **Check:** Add the narrowest candidate index in the lab and refresh statistics.
   - **Reason:** Test one targeted change and make the result reproducible.
   - **Result:** A B-tree index on `public.support_tickets(customer_email)` was created and the table was analyzed.
5. **Check:** Re-run the same query and execution-plan capture.
   - **Reason:** Validate the access path and resource change rather than assuming the index helped.
   - **Result:** The plan used an index condition, shared buffer hits fell from 703 to 4, and the captured execution time was 0.128 ms.

## Evidence

- Before: sequential scan on `support_tickets`.
- Before: 50,003 rows removed by the filter.
- Before: 703 shared buffer hits.
- After: index condition on `customer_email`.
- After: 4 shared buffer hits.
- After: captured execution time of 0.128 ms.
- Before and after plan captures are [`INC-003-before-seq-scan.png`](../evidence/screenshots/INC-003-before-seq-scan.png) and [`INC-003-after-index.png`](../evidence/screenshots/INC-003-after-index.png).
- Reproduction SQL is in [`sql/performance-index.sql`](../sql/performance-index.sql).
- **Evidence limitation:** A before execution-time value, production request volume, customer latency, and index write overhead were not captured. We should not claim a specific end-user latency reduction.

## Root cause

- **Root cause:** No index supported the equality predicate on `public.support_tickets(customer_email)`, so PostgreSQL used a sequential scan.
- **Contributing factors:** The dataset had grown to approximately 50,000 generated rows beyond the initial records, while the lookup pattern remained unchanged.
- **Why the initial symptom could be misleading:** A slow request can come from the application, network, locks, or database execution. The execution plan established that this case involved unnecessary table scanning.

## Remediation

- **Fix applied in the lab:**

  ```sql
  create index idx_support_tickets_customer_email
  on public.support_tickets(customer_email);

  analyze public.support_tickets;
  ```

- **Why this is the smallest lab fix:** It adds one B-tree index for the exact equality predicate and does not change application behavior or data.
- **Trade-offs considered:** The index consumes storage and adds write/maintenance work. In production, confirm query frequency, selectivity, table size, write rate, and deployment method before creating it.
- **Production safety:** Use an appropriate deployment strategy for the environment, such as a concurrent index build where supported and appropriate, and monitor the operation.
- **Rollback or recovery plan:** Remove the index only after confirming that it is not needed and that the query has a safe alternative. Do not remove it during an incident solely because the schema change is unfamiliar.
- **Lab-only limitation:** The measured plan improvement is valid for this seeded dataset and query; it is not a guarantee for every production workload.

## Customer-facing response

> **Subject:** Update on the slow support-ticket lookup
>
> Hi [customer],
>
> **What we found:** The lookup was returning the correct ticket, but the database was scanning a large portion of the table to find it. We confirmed this from the PostgreSQL execution plan rather than assuming the delay was caused by the application.
>
> **What we changed:** We tested a targeted index for the `customer_email` lookup and refreshed the table statistics. In the test environment, PostgreSQL changed from a sequential scan to an indexed lookup.
>
> **How we verified it:** We ran the same query again and confirmed the indexed access path and a reduction in shared buffer hits from 703 to 4. We are continuing to check workload and deployment impact before treating this as a production change.
>
> **Next step:** We will monitor the affected request and confirm whether the same query pattern and workload exist in your environment. I will provide the next update after that review.
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Not for the isolated lab reproduction; escalate if the query is timing out, affects a critical workflow, or needs a high-risk production index deployment.
- **Team or owner:** Database/application owner for workload confirmation and production rollout planning.
- **Technical summary:** Equality lookup on `customer_email` used a sequential scan over the seeded table. `EXPLAIN (ANALYZE, BUFFERS)` showed 50,003 rows removed by filter and 703 shared buffer hits. A targeted B-tree index changed the plan to an index condition with 4 shared buffer hits.
- **Evidence attached:** Before/after execution-plan screenshots and reproduction SQL.
- **Customer impact and urgency:** Slow but successful lookup in the simulation; production impact and SLA effect were not measured.
- **Specific question or decision needed:** Is this predicate frequent and selective enough in production to justify the index’s storage and write cost, and what deployment method is safe for the workload?
- **Next owner and follow-up time:** Application/database owner to confirm production workload; support to update the customer after validation.

## Recovery validation

- **Original failing test:** The exact lookup used a sequential scan and removed 50,003 rows by filter.
- **Post-fix result:** The same lookup used an index condition, reduced shared buffer hits from 703 to 4, and recorded 0.128 ms execution time in the lab.
- **Data validation:** The query continued to return the expected ticket after the index was created.
- **Scope validation:** The result is confirmed for the seeded table and one query; broader workload behavior was not tested.
- **Monitoring or follow-up period:** Not applicable to the lab; production would monitor query latency, plan changes, write overhead, and index health after rollout.

## Prevention and learning

- Capture execution plans for important lookup queries before and after schema changes.
- Keep table statistics current and check existing indexes before proposing new ones.
- Track query frequency, selectivity, latency, and write cost before applying a production index.
- Document the difference between database execution time and total request latency.
- Add a runbook step to verify that the plan improvement persists under realistic data volume and concurrency.
- **Transferable lesson:** Use evidence from the execution plan to identify the bottleneck, apply one targeted change, and validate both query correctness and resource use.
