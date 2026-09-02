# QUEUE-001 — Triage after new evidence

> **Simulation only:** This is a second-stage exercise. The evidence is fictional and does not represent a production queue or SLA event.

## New evidence received after the first acknowledgements

- **TKT-101:** A controlled request to a known-good endpoint succeeds; the 500 is limited to one customer route immediately after their deployment. No other customer project is affected.
- **TKT-103:** A redacted policy diff shows the customer changed an insert policy from the intended authenticated condition to a path condition that does not match their client’s object prefix. Downloads remain successful.
- **TKT-104:** A query plan shows a sequential scan, but requests are completing and only the search endpoint is affected.
- **TKT-105:** The customer corrected the resource spelling and received HTTP 200 from the same client.
- **TKT-102:** A second employee now receives the same login error.
- **TKT-106:** The reporting job’s edited secret was copied with a trailing space; no application connection failures are observed.

## Updated decisions

| Ticket | Initial position | Updated position | Why it changed |
|---|---:|---:|---|
| TKT-101 | 1 / S1-P1 | 3 / S2-P2 | The control request succeeds and the issue is isolated to the customer deployment, so a platform-wide outage is no longer the leading explanation. |
| TKT-103 | 2 / S2-P1 | 1 / S2-P1 | The policy diff and three-user impact confirm a blocked core workflow with a narrow, actionable authorization mismatch. |
| TKT-104 | 3 / S2-P2 | 4 / S2-P2 | The query is degraded but not failing; it remains important after the two confirmed blocked workflows. |
| TKT-105 | 4 / S3-P2 | Closed / S3-P3 | The corrected request returned 200, confirming route/resource spelling as the issue. |
| TKT-102 | 5 / S3-P3 | 2 / S2-P1 | Scope expanded from one user to two, making an account-specific diagnosis less likely and raising the importance of Auth investigation. |
| TKT-106 | 6 / S3-P3 | Closed / S3-P3 | The customer identified a local configuration error and application connectivity remains healthy. |

## Actions after reprioritization

1. Keep TKT-103 first: confirm the intended path convention, apply the narrow correction through the customer’s change process, and retest authenticated success plus anonymous denial.
2. Escalate TKT-102 to Auth review with redacted timestamps and scope comparison; check whether a shared client/project or account-state issue exists.
3. Reclassify TKT-101 as customer-deployment troubleshooting and request a rollback comparison or deploy diff without declaring a platform incident.
4. Continue the low-risk TKT-104 plan review and quantify the index trade-off before recommending a production change.

This update demonstrates that triage is a living decision: new evidence can lower one ticket and raise another without treating the first classification as permanent.
