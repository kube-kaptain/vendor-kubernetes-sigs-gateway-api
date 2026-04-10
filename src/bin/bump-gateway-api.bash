#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025-2026 Kaptain contributors (Fred Cooke)
#
# Finds the next stable Gateway API release after the current version,
# updates the version file, and runs the update script to fetch manifests.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION_FILE="${REPO_ROOT}/src/config/GatewayApiVersion"

# 1. Read current version
CURRENT="$(cat "${VERSION_FILE}" | tr -d '[:space:]')"
echo "Current version: ${CURRENT}"

# 2. Fetch stable release tags from upstream (no clone needed)
echo "Fetching tags from kubernetes-sigs/gateway-api..."
TAGS="$(gh api repos/kubernetes-sigs/gateway-api/tags --paginate -q '.[].name')"

# 3. Filter to stable releases only (vX.Y.Z, no -rc, no monthly-)
STABLE_VERSIONS="$(echo "${TAGS}" \
  | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
  | grep -v '\-' \
  | sed 's/^v//' \
  | sort -V)"

# 4. Find the next version after current
FOUND_CURRENT=false
NEXT=""
while IFS= read -r ver; do
  if [[ "${FOUND_CURRENT}" == "true" ]]; then
    NEXT="${ver}"
    break
  fi
  if [[ "${ver}" == "${CURRENT}" ]]; then
    FOUND_CURRENT=true
  fi
done <<< "${STABLE_VERSIONS}"

if [[ "${FOUND_CURRENT}" != "true" ]]; then
  echo "ERROR: Current version ${CURRENT} not found in upstream tags."
  exit 1
fi

if [[ -z "${NEXT}" ]]; then
  echo "No newer stable version found after ${CURRENT}. Already at latest."
  exit 0
fi

echo "Next version: ${NEXT}"

# 5. Update version file
echo "${NEXT}" > "${VERSION_FILE}"
echo "Updated ${VERSION_FILE} to ${NEXT}"

# 6. Run the update script to fetch manifests
echo
exec "${REPO_ROOT}/.github/bin/update-gateway-api.bash"
