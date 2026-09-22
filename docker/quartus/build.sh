#!/usr/bin/env bash
# Builds the hermes-lite-quartus image from the installer staged by
# download-quartus.sh. See README.md.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

ENV_FILE=.env
[[ -f "$ENV_FILE" ]] || { echo "No .env found — run ./download-quartus.sh first." >&2; exit 1; }
# shellcheck disable=SC1090
source "$ENV_FILE"

[[ -n "${QUARTUS_INSTALLER_NAME:-}" ]] || { echo "QUARTUS_INSTALLER_NAME not set in .env — run ./download-quartus.sh first." >&2; exit 1; }
[[ -f "installers/${QUARTUS_INSTALLER_NAME}" ]] || { echo "installers/${QUARTUS_INSTALLER_NAME} not found." >&2; exit 1; }

echo "Building hermes-lite-quartus (the installer fetches Quartus over the network"
echo "during this build, so it's slow and needs internet access; final image is"
echo "several GB)..."
docker build --build-arg "QUARTUS_INSTALLER_NAME=${QUARTUS_INSTALLER_NAME}" -t hermes-lite-quartus .
