# CloudEco Benchmark Plan (Stage 8/9 Preparation)

## Purpose
Build reproducible performance evidence for FIT5225 A1 by measuring how CloudEco API capacity changes when Kubernetes pod count scales from 1 to 2, 4, and 8.

## Fixed Test Dimensions
- Deployment: `cloudeco-api`
- Namespace: `cloudeco`
- Pod counts: `1`, `2`, `4`, `8`
- API workload mix: from `load_tests/locustfile.py` (`/api/predict` and `/api/annotate`)
- Hosts:
  - `http://48.193.42.240:30080`
  - `http://52.243.56.225:30080`

## User Ladder (Gradual Concurrency)
Suggested exploratory ladder:
- `1, 2, 4, 8, 12, 16, 24, 32`

Stop early for a pod setting if either appears:
- sustained non-trivial failures, or
- clear exponential latency growth.

## Duration Strategy
- Exploratory runs: `2m` per user level.
- Final selected threshold runs: `3m` to `5m` for stronger evidence.

## Stability and Breaking Point
Stable (recommended rule):
- Failure rate <= `1%`, and
- P95 latency does not show runaway growth versus previous level.

Breaking point:
- Failure rate > `1%` sustained, or
- latency jumps sharply between adjacent user levels with visible saturation.

Record the **maximum stable concurrent users** per pod count.

## Metrics to Record Per Run
- `concurrent_users`
- `spawn_rate`
- `duration`
- `total_requests`
- `total_failures`
- `failure_rate_percent`
- `avg_response_time_ms`
- `median_response_time_ms`
- `p95_response_time_ms`
- `requests_per_second`
- stability decision (`stable`)
- notes (timeouts, anomalies, host used, etc.)

## Data Integrity (No Fabrication)
- Every table value must come from Locust output files or console summary.
- Keep raw CSV files for each run under `load_tests/results/`.
- Keep naming consistent via output prefix (example: `pod4_users16`).
- Do not backfill missing runs with estimates.

## Evidence Preservation
For each run, keep:
- Locust CSV outputs (`*_stats.csv`, `*_stats_history.csv`, `*_failures.csv`, `*_exceptions.csv`)
- One row in `benchmark_results_template.csv` (or derived results file)
- Optional short run note in `notes`

## Link to Final 500-Word Report
This benchmark process provides:
- the 1/2/4/8 results table,
- concurrency-vs-latency plots for at least two configurations,
- bottleneck/saturation discussion,
- Little's Law style interpretation (throughput, concurrency, latency relationship) grounded in measured data.
