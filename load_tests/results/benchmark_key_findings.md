# Benchmark Key Findings

Based on Aggregated rows from Locust request CSV files under `load_tests/results/`.
No raw CSV values were edited.

## Per-Pod Summary

| pod_count | max_stable_users | breaking_point_users | best_observed_rps | avg_ms_at_max_stable | p95_ms_at_max_stable |
|---:|---:|---:|---:|---:|---:|
| 1 | 4 | 8 | 0.6051 | 4920.45 | 5900.00 |
| 2 | 12 | 16 | 1.1201 | 8555.95 | 15000.00 |
| 4 | 16 | 48 | 3.2952 | 3248.54 | 7800.00 |
| 8 | 112 | 145 | 8.1711 | 5541.39 | 18000.00 |

## Technical Interpretation

- Horizontal scaling increased total throughput from 1 pod to 8 pods.
- Scaling was not linear: per-pod efficiency dropped at higher concurrency.
- YOLO inference under the fixed 1 vCPU pod limit is the dominant bottleneck.
- As users increased, RPS eventually plateaued while average and p95 latency rose sharply, indicating queueing/saturation.
- This aligns with the assignment requirement to identify breaking points and latency degradation under load.
- For 8 pods, the 145-user point is treated as borderline saturation; it has the highest observed RPS but is not counted as maximum stable concurrency.

## Stability Rule Used

- Stable if failure_rate_percent < 1 and no clear saturation signal.
- Unstable if failure_rate_percent >= 1 or latency jumped sharply while RPS stopped improving.
- Borderline points are flagged in `notes` and excluded from max stable user selection when classified as saturation risk.