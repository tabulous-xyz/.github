#!/usr/bin/env sh

set -eux pipefail

npm install

echo $GITHUB_TOKEN | docker login ghcr.io -u tabulous-bot --password-stdin
