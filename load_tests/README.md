# Load Testing (Locust)

## Smoke Test
Run a quick 30-second smoke test (no benchmark):

```bash
locust -f load_tests/locustfile.py --headless -u 1 -r 1 -t 30s --host http://48.193.42.240:30080
```

You can swap host to worker-2:

```bash
locust -f load_tests/locustfile.py --headless -u 1 -r 1 -t 30s --host http://52.243.56.225:30080
```

## What It Sends
- `POST /api/predict`
- `POST /api/annotate`

Each request includes:
- `uuid`: fresh UUID
- `image`: base64 content from `test_assets/image0.jpeg`

## Next Stage (Benchmark)
Use this same script for controlled experiments at 1, 2, 4, and 8 pods.
