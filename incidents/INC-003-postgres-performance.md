# INC-003 - PostgreSQL selective lookup / missing index

## Simulated customer ticket

> Looking up a ticket by customer email becomes slow after the table grows.
> Other application functions remain available.

## Impact and scope

A repeated selective read path is slower than expected. This is not automatically
an outage, and a sequential scan is not automatically incorrect.

## Original evidence

The original `EXPLAIN (ANALYZE, BUFFERS)` capture showed:

- sequential scan on `support_tickets`
- 50,003 rows removed by filter
- 703 shared buffer hits

After adding a B-tree index on `customer_email`, the captured plan used the index
condition, shared buffer hits fell to 4 and one lab execution took 0.128 ms.
That timing is one captured run, not a universal performance guarantee.

## Investigation and decision

The equality predicate returned one row from about 50,004, making it selective.
The lookup represented a repeated access pattern and no suitable index existed.
Those facts justified testing a B-tree index.

## Fix

See `sql/performance-index.sql`. The file now drops the lab index first so the
before plan can be reproduced, creates the index, analyzes the table and captures
the same query again.

## Trade-offs

- Indexes consume storage.
- Inserts and updates must maintain the index.
- A sequential scan may remain correct for a small table or low-selectivity query.
- `EXPLAIN ANALYZE` executes the statement and must be used cautiously in
  production, especially for writes or expensive queries.

## Validation required for Version 2

- save the complete before plan as text
- save the complete after plan as text
- repeat executions and record whether results remain consistent
- confirm the returned row is unchanged
- document table size and selectivity at test time

Clean Version 2 plan output is pending hosted execution.

## Customer-facing resolution

The query was filtering a large table by a highly selective email value without
an index that matched the predicate. We added a B-tree index for that repeated
lookup and compared the same plan before and after. The updated plan avoided the
full-table filtering observed in the lab. We would continue monitoring the real
workload because the index also adds storage and write-maintenance cost.
