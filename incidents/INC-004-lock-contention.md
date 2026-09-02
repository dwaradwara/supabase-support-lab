# INC-004 — PostgreSQL lock contention

This is a self-directed simulated incident in a hosted Supabase project. It is not a production customer case.

## Incident metadata

- **Incident ID:** `INC-004`
- **Title:** Competing sessions could not acquire the same logical lock
- **Status:** Resolved in the lab
- **Severity:** Provisional S2 / moderate workflow impact
- **Priority:** P2 while the blocked operation and scope were being confirmed
- **Affected area:** PostgreSQL transactions / advisory locks / session blocking
- **Customer impact:** A workflow waiting for a logical resource could not proceed while another session held the corresponding advisory lock. The lab does not establish a production outage, timeout, or SLA breach.
- **Detection or report:** Simulated report that an operation was waiting for another database operation to finish.

## Customer symptom

The customer reported that an operation involving a shared logical resource was not progressing.

The first task is to determine whether the request is blocked by a database lock, slow because of query execution, waiting on an external dependency, or already failed. A blocked request should not automatically be treated as a database outage.

## Initial assessment

- **What is confirmed:** Session A held advisory transaction lock `424242`; Session B could not acquire the same logical lock while Session A was active.
- **What is not yet confirmed:** Whether a real application transaction is blocked, how many sessions are affected, whether the lock is expected, how long it has been held, and whether cancellation would be safe.
- **Initial assumptions:** The two sessions represent application operations competing for one logical resource. The lock ID is a lab identifier, not a production resource name.
- **Immediate safety concern:** Do not terminate a database session or roll back a transaction without identifying the blocker, understanding its work, and checking the impact of cancellation.
- **First customer update:** Acknowledge that the operation is waiting, confirm that the team is checking for database blocking, and provide the next update after the blocker/waiter relationship and scope are known.

## Triage and prioritization

- **Why this priority was selected:** One logical operation was blocked in the simulation, but no broad outage or data-integrity problem was established. It was treated as P2 provisionally.
- **Who or what may be affected:** Sessions competing for the same logical resource. Scope must be measured through active sessions and lock relationships.
- **What I would investigate first:** Identify the waiting session, blocking session, lock type, transaction age, affected query, and customer impact; check whether the blocker is still making progress.
- **What I would defer:** Killing the blocker, restarting services, changing timeout settings, and blaming PostgreSQL without evidence.
- **Escalation trigger:** Escalate if many customers are blocked, the blocker is idle in transaction, data changes are at risk, the lock persists beyond the expected business operation, or safe cancellation is unclear.

## Investigation

1. **Check:** Confirm whether the customer operation is blocked or simply slow.
   - **Reason:** Different causes require different actions and escalation paths.
   - **Result in the lab:** A second session could not acquire the logical lock while Session A held it.
2. **Check:** Inspect active sessions and lock relationships using `pg_stat_activity` and `pg_locks`.
   - **Reason:** Identify the blocker, waiter, transaction state, query, and duration before taking action.
   - **Result for this deterministic reproduction:** Session A represented the holder and Session B represented the waiter.
3. **Check:** Determine whether the lock is transaction-scoped and whether the holding transaction is progressing.
   - **Reason:** A transaction-scoped lock should be released when the transaction completes; an idle or abandoned transaction may require escalation.
   - **Result in the lab:** Session A held an advisory transaction lock briefly with `pg_sleep(30)`.
4. **Check:** Retry a non-blocking acquisition from Session B.
   - **Reason:** Avoid making the diagnostic session wait and obtain a direct signal about lock ownership.
   - **Result:** `pg_try_advisory_xact_lock(424242)` returned `false` while Session A held the lock and `true` after it completed.

## Evidence

- Session A acquired advisory transaction lock `424242` and slept for 30 seconds.
- Session B returned `false` from `pg_try_advisory_xact_lock(424242)` while the lock was held.
- The same request returned `true` after Session A completed and released the lock.
- Reproduction SQL is in [`sql/lock-contention.sql`](../sql/lock-contention.sql).
- **Evidence limitation:** No production session IDs, customer count, wait duration beyond the 30-second lab sleep, timeout, or data-integrity impact were captured. Those details must not be invented.

## Root cause

- **Root cause:** The logical resource was already held by another PostgreSQL session through an advisory transaction lock.
- **Contributing factors:** Session B attempted to acquire the same lock while Session A still owned it.
- **Why the initial symptom could be misleading:** A customer may describe the result as a hung application, but the actual cause could be database blocking, a slow query, a network dependency, or a client timeout. Lock evidence narrows the cause.

## Remediation

- **Fix applied in the lab:** Session A completed, releasing the transaction-scoped advisory lock. Session B then retried and acquired it successfully.
- **Why this is the smallest safe fix:** The deterministic lab blocker was allowed to complete; no session was terminated and no data was changed.
- **Production safety:** Identify the blocker and confirm whether it is active, idle, expected, or abandoned before cancelling it. Preserve the customer’s transaction and coordinate with the application owner when rollback could lose work.
- **Rollback or recovery plan:** If a production blocker must be cancelled, record the session/query evidence, notify the owner, cancel the narrowest safe operation, and validate the affected workflow afterward.
- **Lab-only limitation:** The `pg_sleep(30)` holder is a controlled reproduction and does not represent a realistic business transaction duration.

## Customer-facing response

> **Subject:** Update on the operation waiting to proceed
>
> Hi [customer],
>
> **What we found:** The operation was waiting for another database session that held the same logical resource. This is a blocking condition, not evidence that the database or your data has been lost.
>
> **What we are checking:** We are identifying the holding operation, how long it has been active, whether it is still making progress, and whether other customers are affected. We will avoid terminating a session until we understand the effect on its work.
>
> **Next step:** Once the holding operation completes or a safe intervention is approved, we will retry the original operation and confirm that it completes successfully.
>
> **How we will verify the fix:** We will confirm that the waiting operation acquires the resource, that the customer workflow succeeds, and that no unintended transaction or data issue was introduced.
>
> I will provide the next update after the blocker and affected scope are confirmed.
>
> Regards,
> [Support Engineer]

## Internal escalation and handoff

- **Escalation needed:** Not for the isolated lab reproduction; escalate if a real blocker is long-lived, broad, idle in transaction, or unsafe to cancel.
- **Team or owner:** Database/application owner; involve incident leadership if customer impact is broad or critical workflows are stalled.
- **Technical summary:** Session A held advisory transaction lock `424242` for a controlled 30-second interval. Session B’s non-blocking acquisition returned `false`, then `true` after Session A completed.
- **Evidence attached:** `pg_stat_activity`/`pg_locks` investigation output where available and the lock-contention reproduction SQL.
- **Customer impact and urgency:** One simulated logical operation was blocked; production scope and SLA effect were not measured.
- **Specific question or decision needed:** Is the holding transaction expected and progressing, or should the owner approve cancellation and retry?
- **Next owner and follow-up time:** Database/application owner to assess the blocker; support to update the customer after the retry.

## Recovery validation

- **Original failing test:** `pg_try_advisory_xact_lock(424242)` returned `false` while Session A held the lock.
- **Post-fix result:** The same non-blocking acquisition returned `true` after Session A completed.
- **Workflow validation:** The lab confirms lock acquisition recovery; a production test must also confirm the original customer operation and transaction outcome.
- **Scope validation:** The reproduction covers one logical lock ID and two sessions; broader lock impact was not tested.
- **Monitoring or follow-up period:** Not applicable to the lab; production would monitor blocked sessions, transaction age, lock duration, and recurrence.

## Prevention and learning

- Review transaction boundaries and ensure locks are released promptly.
- Avoid long-running or idle-in-transaction sessions while holding application locks.
- Add monitoring for blocked sessions, lock duration, and transaction age.
- Document the difference between advisory locks and relation/row locks.
- Include blocker/waiter evidence in every production escalation.
- **Transferable lesson:** Confirm the blocker and its business impact before intervening; use the smallest safe action and validate the original workflow afterward.
