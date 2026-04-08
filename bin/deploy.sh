#!/usr/bin/env sh

set -eu pipefail

TAG=$(cat package.json | jq -r '.version')

echo "ACTIONS_RUNNER_TOKEN=$(aws ssm get-parameter --name /config/github/ACTIONS_RUNNER_TOKEN | jq -r '.Parameter.Value')" > .env
aws s3 cp .env "s3://env-579342189565-us-east-1/github/${TAG}/.env"
rm .env

cat > parameters.json <<EOF
[
    {
        "ParameterKey": "LogGroupName",
        "ParameterValue": "/config/github/ACTIONS_CLOUDWATCH_LOG_GROUP_NAME"
    },
    {
        "ParameterKey": "LogRegionName",
        "ParameterValue": "/config/github/ACTIONS_CLOUDWATCH_LOG_REGION_NAME"
    },
    {
        "ParameterKey": "LogStreamPrefix",
        "ParameterValue": "/config/github/ACTIONS_CLOUDWATCH_LOG_STREAM_PREFIX"
    },
    {
        "ParameterKey": "LogDriverName",
        "ParameterValue": "/config/github/ACTIONS_CLOUDWATCH_LOG_DRIVER_NAME"
    },
    {
        "ParameterKey": "EcrImageTag",
        "ParameterValue": "$TAG"
    },
    {
        "ParameterKey": "EcrImageUri",
        "ParameterValue": "/config/github/ACTIONS_RUNNER_ECR_IMAGE_URI"
    },
    {
        "ParameterKey": "EcsTaskDefinitionFamily",
        "ParameterValue": "/config/github/ACTIONS_RUNNER_ECS_TASK_DEFINITION_FAMILY"
    },
    {
        "ParameterKey": "IamRoleArn",
        "ParameterValue": "/config/github/ACTIONS_RUNNER_IAM_ROLE_ARN"
    },
    {
        "ParameterKey": "EcsClusterArn",
        "ParameterValue": "/config/github/ACTIONS_ECS_CLUSTER_ARN"
    },
    {
        "ParameterKey": "EcsServiceName",
        "ParameterValue": "/config/github/ACTIONS_ECS_SERVICE_NAME"
    },
    {
        "ParameterKey": "EnvironmentFile",
        "ParameterValue": "arn:aws:s3:::env-579342189565-us-east-1/github/${TAG}/.env"
    }
]
EOF

aws cloudformation deploy \
    --stack-name=github-actions \
    --template-file=template.yml \
    --parameter-overrides file://parameters.json
