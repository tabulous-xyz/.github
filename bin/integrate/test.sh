#!/usr/bin/env bash

set -euox pipefail

echo "::group::Setup Docker"
cp .docker/config.json ~/.docker/config.json
docker buildx create --use --driver-opt network=host
echo "::endgroup::"

docker buildx build \
  --file runner/Dockerfile \
  --build-arg=DOCKER_BASE_IMAGE_URI=$DOCKER_BASE_IMAGE_URI \
  --cache-from "$RUNNER_DOCKER_CACHE_FROM" \
  --cache-to "$RUNNER_DOCKER_CACHE_TO" \
  --provenance false \
  --push \
  --tag=$RUNNER_ECR_REPOSITORY_URI .
