#!/usr/bin/env sh

export DOCKER_BASE_IMAGE_URI=$(gh variable get -R tabulous-xyz/workflow DOCKER_BASE_IMAGE_URI)
export RUNNER_ECR_REPOSITORY_URI=$(gh variable get RUNNER_ECR_REPOSITORY_URI)

aws ecr get-login-password \
  --region us-east-1 | docker login \
    --username AWS \
    --password-stdin 579342189565.dkr.ecr.us-east-1.amazonaws.com
