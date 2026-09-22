#!/usr/bin/env bash
# Compiles one gateware variant inside the hermes-lite-quartus image.
# Usage: ./compile.sh radioberry_pio_cl016
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

variant="${1:-}"
[[ -n "$variant" ]] || { echo "Usage: $0 <variant>  (e.g. radioberry_pio_cl016)" >&2; exit 1; }

REPO_ROOT="$(cd ../.. && pwd)"
VARIANT_DIR="gateware/variants/${variant}"
[[ -d "${REPO_ROOT}/${VARIANT_DIR}" ]] || { echo "No such variant: ${VARIANT_DIR}" >&2; exit 1; }

docker image inspect hermes-lite-quartus >/dev/null 2>&1 || { echo "Image hermes-lite-quartus not built yet — run ./build.sh first." >&2; exit 1; }

echo "Compiling ${variant} (this can take a while)..."
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "${REPO_ROOT}/gateware:/work/gateware" \
  -w "/work/${VARIANT_DIR}" \
  hermes-lite-quartus \
  make
