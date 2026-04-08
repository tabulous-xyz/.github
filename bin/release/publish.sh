#!/usr/bin/env sh

NEXT_VERSION=$1;

set -eux pipefail

MAJOR_VERSION=$(echo "$NEXT_VERSION" | cut -d. -f1)

git tag -f "v$MAJOR_VERSION"

git push origin HEAD:release
git push origin -f "v$MAJOR_VERSION"
