#!/usr/bin/env bash
set -euo pipefail

# Run TensorFlow Serving in a Docker container and serve the exported model.
# Exposes:
# - gRPC on localhost:9500
# - REST on localhost:9501
#
# Assumes you have already exported the model to:
# ./saved_model_half_plus_two/1
# (Running half_plus_two.py should create that directory.)

docker run -t --rm \
  -p 9500:8500 \
  -p 9501:8501 \
  -v "$(pwd)/saved_model_half_plus_two:/models/half_plus_two" \
  -e MODEL_NAME=half_plus_two \
  tensorflow/serving
