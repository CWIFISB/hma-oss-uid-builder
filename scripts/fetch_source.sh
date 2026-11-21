#!/usr/bin/env bash
# Clone the private source into ./src using SOURCE_REPO_TOKEN and init submodules.
# NOTE: we use --filter=blob:none (partial clone) instead of --depth 1 because
# build.gradle.kts derives versionName/versionCode from
#   git rev-list refs/remotes/origin/master --count
# A shallow clone would report 1 commit and break the version (oss--431).
set -euo pipefail
: "${SOURCE_REPO_TOKEN:?SOURCE_REPO_TOKEN secret is required}"
SRC_REPO="${SOURCE_REPO_REPO:-CWIFISB/hma-oss-uid}"
SRC_REF="${SOURCE_REF:-master}"
git clone --recursive --filter=blob:none --branch "$SRC_REF" \
  "https://x-access-token:${SOURCE_REPO_TOKEN}@github.com/${SRC_REPO}.git" src
# ensure the origin/<default> ref exists for rev-list counting
cd src
git fetch origin "$SRC_REF":refs/remotes/origin/master || true
echo "Fetched ${SRC_REPO}@${SRC_REF} -> src ($(git rev-list refs/remotes/origin/master --count) commits)"
