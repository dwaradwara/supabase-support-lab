# Runbook — PostgreSQL query performance

1. Capture the exact slow SQL.
2. Run `EXPLAIN (ANALYZE, BUFFERS)`.
3. Check scan type, row estimates, rows removed by filter and buffer usage.
4. Verify statistics are current with `ANALYZE`.
5. Add or modify an index only when justified by the access pattern.
6. Re-run the identical plan after the change.
7. Compare scan type, buffers and execution time.
8. Document tradeoffs: indexes improve reads but add storage/write overhead.
