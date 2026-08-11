# INC-003 — PostgreSQL slow lookup / missing index

## Symptom
A lookup for one support ticket by `customer_email` scanned almost the entire table.

## Evidence before fix
`EXPLAIN (ANALYZE, BUFFERS)` showed:
- Sequential scan on `support_tickets`
- 50,003 rows removed by filter
- 703 shared buffer hits

## Investigation
The query filtered on `customer_email`, but no index supported that predicate.

## Root cause
Missing index on `public.support_tickets(customer_email)`.

## Fix

```sql
create index idx_support_tickets_customer_email
on public.support_tickets(customer_email);

analyze public.support_tickets;
```

## Recovery validation
The same query used the index path:
- `Index Cond` on `customer_email`
- shared buffer hits reduced from 703 to 4
- captured execution time: 0.128 ms
- full-table filtering was eliminated

## Evidence
- [Before: sequential scan](../evidence/screenshots/INC-003-before-seq-scan.png)
- [After: indexed lookup](../evidence/screenshots/INC-003-after-index.png)

## Learning
Use `EXPLAIN (ANALYZE, BUFFERS)` to confirm the access path before and after an index change rather than assuming the index improved the query.
