#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
IMAGE_NAME="${1:-}"
PORT_LOCAL=9000
PORT_CONTAINER=8080

# --- VALIDATION ---
if [[ -z "$IMAGE_NAME" ]]; then
    echo "ERROR: Image name not provided."
    echo "Usage: ./build_and_run.sh <image-name>"
    exit 1
fi

# --- BUILD ---
echo "Building Docker image: $IMAGE_NAME"
if ! docker build -t "$IMAGE_NAME" .; then
    echo "Docker build failed."
    exit 1
fi
echo "Build complete!"

# --- RUN ---
echo "Running docker container"
docker run -d -p "$PORT_LOCAL":"$PORT_CONTAINER" "$IMAGE_NAME":latest
CONTAINER_ID=$(docker ps -lq)

if [[ -z "$CONTAINER_ID" ]]; then
    echo "Docker container failed to start."
    exit 1
fi

echo "Container started: $CONTAINER_ID"

# --- TEST ---
echo "Sending test invocation"
curl -X POST -H "Content-Type: application/json" -d '{}' http://localhost:9000/2015-03-31/functions/function/invocations

# --- CLEAN UP ---
cleanup() {
    if [[ -n "${CONTAINER_ID:-}" ]]; then
        echo "Cleaning up container $CONTAINER_ID"
        docker kill "$CONTAINER_ID" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_ID" >/dev/null 2>&1 || true
        echo "Container removed."
    fi
}
trap cleanup EXIT