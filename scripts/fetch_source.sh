#!/usr/bin/env bash
# Clone the private source into ./src using SOURCE_REPO_TOKEN and init submodules.
set -euo pipefail
: "${SOURCE_REPO_TOKEN:?SOURCE_REPO_TOKEN secret is required}"
SRC_REPO="${SOURCE_REPO_REPO:-CWIFISB/hma-oss-uid}"
SRC_REF="${SOURCE_REF:-master}"
git clone --recursive --depth 1 --branch "$SRC_REF" \
  "https://x-access-token:${SOURCE_REPO_TOKEN}@github.com/${SRC_REPO}.git" src
echo "Fetched ${SRC_REPO}@${SRC_REF} -> src"
