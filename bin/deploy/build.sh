#!/usr/bin/env sh

set -eu pipefail

# RELEASE_VERSION=$(cat package.json | jq -r '.version')
# VERSION="${GITHUB_REF_NAME#v}"

# docker run \
#   -v build:/metronome/.build \
#   $ECR_REPOSITORY_URI:$VERSION \
#   build \
#   --dns-alias-hosted-zone-name=$DNS_ALIAS_HOSTED_ZONE_NAME \
#   --dns-alias-name=$DNS_ALIAS_NAME \
#   --dns-target-hosted-zone-id=$DNS_TARGET_HOSTED_ZONE_ID \
#   --dns-target-name=$DNS_TARGET_NAME \
#   --ecr-image-uri=$ECR_REPOSITORY_URI:$VERSION \
#   --ecs-task-definition-family=$ECS_TASK_DEFINITION_FAMILY \
#   --env-s3-bucket-name=$ENV_S3_BUCKET_NAME \
#   --env-s3-object-key=$ENV_S3_OBJECT_KEY \
#   --iam-role-arn=$IAM_ROLE_ARN \
#   --log-driver-name=$LOG_DRIVER_NAME \
#   --log-group-name=$LOG_GROUP_NAME \
#   --log-region-name=$LOG_REGION_NAME \
#   --log-stream-prefix=$LOG_STREAM_PREFIX \
#   --output-dir=./.build \
#   --release-version=$RELEASE_VERSION

# echo "CLOUDFORMATION_DEPLOY_PARAMETER_OVERRIDES=file:///workflow/.build/parameters.json" >> "$GITHUB_OUTPUT"
# echo "CLOUDFORMATION_DEPLOY_TEMPLATE_FILE=template.yml" >> "$GITHUB_OUTPUT"
# echo "CLOUDFORMATION_DEPLOY_STACK_NAME=metronome" >> "$GITHUB_OUTPUT"
