#!/usr/bin/env bash

NEXT_VERSION=$1;

set -euxo pipefail

NPM_PACKAGE_VERSION=$(cat package.json | jq -r '.version')
WORKFLOW_ECR_IMAGE_VERSION_TAG=$WORKFLOW_ECR_REPOSITORY_URI:$NPM_PACKAGE_VERSION
RUNNER_ECR_IMAGE_VERSION_TAG=$RUNNER_ECR_REPOSITORY_URI:$NPM_PACKAGE_VERSION

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
  --tag=$RUNNER_ECR_IMAGE_URI \
  --tag=$RUNNER_ECR_IMAGE_VERSION_TAG \
  --tag=$RUNNER_ECR_REPOSITORY_URI \
  .
