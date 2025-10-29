#!/usr/bin/env bash
set -euo pipefail

# Send a REST prediction request to the TensorFlow Serving container.
# Must have docker-run.sh already running.

curl -X POST \
  http://localhost:9501/v1/models/half_plus_two:predict \
  -d '{
    "signature_name": "serving_default",
    "instances": [[1.0], [2.0], [5.0]]
  }'
echo
