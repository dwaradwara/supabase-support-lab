# Failed first hypothesis — INC-001

> **Simulation/lab evidence:** This example is based on the self-directed INC-001 exercise, not a production customer incident.

## Customer symptom

The Data API returned HTTP 200 with no rows, although the SQL Editor showed four rows in `support_tickets`.

## First hypothesis

The data may be missing, inserted into the wrong project, or filtered by an incorrect query.

That was a reasonable starting hypothesis because an empty result can look like a data-loss or query problem from the client’s perspective. It was not safe to declare it as the root cause.

## Evidence that disproved it

The SQL Editor confirmed that the intended table contained four rows. The request also used the expected table route. This disproved “the data is absent” for the tested project and table.

## Revised hypothesis

The request was reaching the Data API under a role whose RLS policy did not permit row visibility. The next investigation therefore moved to the effective request role and table policies instead of changing the data or query.

## Corrective lesson

An empty Data API response is not automatically evidence of deleted data. Compare database visibility, request role, policy behavior, filters, and project target before changing records or weakening RLS.

## How I would explain this in an interview

> “My first hypothesis was that the rows were missing or the client was querying the wrong place. I checked the database and found four rows, so that hypothesis was disproved. I then shifted to request-role and RLS analysis. The important behavior was not that I guessed RLS immediately; it was that I let the evidence change the investigation.”
