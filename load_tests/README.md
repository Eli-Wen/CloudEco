# Load Testing (Locust)

## Smoke Test
Run a quick 30-second smoke test (no benchmark).  
Use `mixed` mode to verify both endpoints in one short run:

```bash
CLOUDECO_ENDPOINT_MODE=mixed locust -f load_tests/locustfile.py --headless -u 1 -r 1 -t 30s --host http://48.193.42.240:30080
```

You can swap host to worker-2:

```bash
CLOUDECO_ENDPOINT_MODE=mixed locust -f load_tests/locustfile.py --headless -u 1 -r 1 -t 30s --host http://52.243.56.225:30080
```

## Single Benchmark Run
Use the helper script for one controlled run (does not scale pods).  
Formal benchmark recommendation: `predict` mode.

```powershell
.\load_tests\run_single_locust_test.ps1 `
  -HostUrl "http://48.193.42.240:30080" `
  -Users 4 `
  -SpawnRate 1 `
  -RunTime "2m" `
  -OutputPrefix "pod1_users4" `
  -EndpointMode "predict"
```

CSV outputs are written to `load_tests/results/`.

## Kubernetes Scaling Helper
Use this only when you intentionally switch pod count for benchmark phases:

```powershell
.\load_tests\scale_k8s_deployment.ps1 -Replicas 1
.\load_tests\scale_k8s_deployment.ps1 -Replicas 2
.\load_tests\scale_k8s_deployment.ps1 -Replicas 4
.\load_tests\scale_k8s_deployment.ps1 -Replicas 8
```

## Pod Ladder Helper (Controlled)
Run one pod-count ladder at a time with manual stop checkpoints between levels.

1 pod formal benchmark example (predict-only):

```powershell
.\load_tests\run_pod_ladder.ps1 -PodCount 1 -HostUrl "http://48.193.42.240:30080" -Users "1,2,4,8" -EndpointMode "predict" -ScaleFirst
```

Later 2/4/8 examples:

```powershell
.\load_tests\run_pod_ladder.ps1 -PodCount 2 -HostUrl "http://48.193.42.240:30080" -Users "1,2,4,8,12,16" -EndpointMode "predict" -ScaleFirst
.\load_tests\run_pod_ladder.ps1 -PodCount 4 -HostUrl "http://48.193.42.240:30080" -Users "1,2,4,8,12,16,24" -EndpointMode "predict" -ScaleFirst
.\load_tests\run_pod_ladder.ps1 -PodCount 8 -HostUrl "http://48.193.42.240:30080" -Users "1,2,4,8,12,16,24,32" -EndpointMode "predict" -ScaleFirst
```

Smoke mixed example via helper:

```powershell
.\load_tests\run_single_locust_test.ps1 -HostUrl "http://48.193.42.240:30080" -Users 1 -SpawnRate 1 -RunTime "30s" -OutputPrefix "smoke_mixed" -EndpointMode "mixed"
```

## What It Sends
- `POST /api/predict`
- `POST /api/annotate`

Each request includes:
- `uuid`: fresh UUID
- `image`: base64 content from `test_assets/image0.jpeg`

## Next Stage (Benchmark)
- Formal experiments must cover `1`, `2`, `4`, and `8` pods.
- Recommended mode for formal scaling benchmark: `predict`.
- `annotate` is heavier (inference + plotting + large base64 response) and should be tested separately or via short mixed smoke checks.
- Keep all raw Locust CSV outputs as evidence.
- Do not treat smoke-test results as final benchmark results.
- See `load_tests/benchmark_plan.md` for the benchmark workflow.
