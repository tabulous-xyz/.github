#!/usr/bin/env sh

. ./bin/develop/env.sh

docker buildx build \
  --build-arg DOCKER_BASE_IMAGE_URI=$DOCKER_BASE_IMAGE_URI \
  -t $ECR_REPOSITORY_URI \
  --load .
