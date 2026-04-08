#!/bin/bash
set -e

if [ -d "/runner/.venv" ]; then
    source /runner/.venv/bin/activate
    echo "Pipenv virtualenv activated. Python path: $(which python)"
fi

# Ensure ACTIONS_RUNNER_TOKEN is set
if [ -z "${ACTIONS_RUNNER_TOKEN}" ]; then
    echo "Error: ACTIONS_RUNNER_TOKEN environment variable is not set."
    exit 1
fi

# ORGANIZATION_URL should be the URL to your GitHub organization (e.g., https://github.com/your-org)
# GITHUB_ORG_NAME should be just the organization name (e.g., your-org)
# For this script, we'll keep the hardcoded values as in your original script.
ORGANIZATION_URL=https://github.com/tabulous-xyz
GITHUB_ORG_NAME=tabulous-xyz

echo "Generating registration token for organization ${GITHUB_ORG_NAME}... 🔑"
# Use -s for silent curl, and add Accept header as good practice
JSON_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token ${ACTIONS_RUNNER_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/${GITHUB_ORG_NAME}/actions/runners/registration-token")

TOKEN=$(echo "${JSON_RESPONSE}" | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "Error: Failed to retrieve a valid registration token from GitHub API."
    echo "Attempted URL: https://api.github.com/orgs/${GITHUB_ORG_NAME}/actions/runners/registration-token"
    echo "Response from GitHub: ${JSON_RESPONSE}"
    echo "Please ensure ACTIONS_RUNNER_TOKEN is valid and has appropriate permissions (e.g., admin:org for PATs)."
    exit 1
fi
echo "Registration token obtained."

# Define runner name, labels, and work directory
# Using a unique name helps with --replace and identifying runners
RUNNER_NAME="ephemeral-runner-$(hostname)-$(uuidgen | cut -c1-8)"
# Use environment variable for labels if provided (e.g., RUNNER_LABELS_ENV), otherwise default
RUNNER_WORKDIR="_work"

echo "Configuring runner: ${RUNNER_NAME} for ${ORGANIZATION_URL}"
exec gosu runner ./config.sh \
    --url "${ORGANIZATION_URL}" \
    --token "${TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "self-hosted" \
    --work "${RUNNER_WORKDIR}" \
    --replace \
    --disableupdate \
    --unattended \
    --ephemeral

echo "Runner configuration complete. Starting runner process... 🚀"
# ./run.sh will block until the runner completes its job and unregisters (due to --ephemeral)
exec gosu runner ./run.sh

echo "Runner process has finished."
