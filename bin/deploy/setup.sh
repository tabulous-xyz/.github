#!/usr/bin/env sh

set -eux pipefail


# touch .env

# VERSION="${GITHUB_REF_NAME#v}"

# docker pull $ECR_REPOSITORY_URI:$VERSION

# SENTRY_RELEASE=metronome@$(cat package.json | jq -r '.version')

# aws ssm get-parameters-by-path --path /config/metronome --with-decryption | jq -r '.Parameters|map("\(.Name | (split("/") | last))=\(.Value)")|.[]' >> .env
# aws ssm get-parameters-by-path --path /config/metronome --with-decryption | jq -r '.Parameters|map("\(.Name | (split("/") | last))=\(.Value)")|.[]' >> app/.env

# echo "SENTRY_RELEASE_VERSION=$GIT_SHA" >> .env
# echo "NODE_ENV=production" >> .env
# echo "AWS_REGION=us-east-1" >> .env

# sentry-cli --version

# npm install -g @sentry/cli

# npx @sentry/cli deploys \
#   --project $SENTRY_PROJECT \
#   --org $SENTRY_ORG \
#   --release $SENTRY_RELEASE \
#   new --env=$SENTRY_ENVIRONMENT --name $SENTRY_DEPLOY
