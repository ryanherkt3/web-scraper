#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
IMAGE_NAME="${1:-}"
AWS_ACCT_ID="${2:-}"
AWS_REGION="ap-southeast-6"
REPO_URL="$AWS_ACCT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:latest"

# --- VALIDATION ---
if [[ -z "$IMAGE_NAME" || -z "$AWS_ACCT_ID" ]]; then
    echo "ERROR: Missing arguments."
    echo "Usage: ./push_to_ecr.sh <image-name> <aws-account-id>"
    exit 1
fi

# Check if local image exists
if ! docker image inspect "$IMAGE_NAME:latest" >/dev/null 2>&1; then
    echo "ERROR: Local Docker image '$IMAGE_NAME:latest' does not exist."
    exit 1
fi

# --- LOGIN ---
if [ "$#" -ge 3 ]; then
    if [ "$3" == "login" ]; then
        echo "Logging into ECR"
        if ! aws ecr get-login-password --region "$AWS_REGION" \
            | docker login --username AWS --password-stdin "$AWS_ACCT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"; then
            echo "ECR login failed."
            exit 1
        fi
    else
        echo "Login argument provided, but is incorrect (should be \"login\")"
    fi
fi

# --- TAG ---
echo "Tagging image '$IMAGE_NAME:latest' → '$REPO_URL'"
if ! docker tag "$IMAGE_NAME:latest" "$REPO_URL"; then
    echo "Failed to tag image."
    exit 1
fi

# --- PUSH ---
echo "Pushing to ECR"
if ! docker push "$REPO_URL"; then
    echo "Failed to push image to ECR."
    exit 1
fi

echo "Successfully pushed to: $REPO_URL"
