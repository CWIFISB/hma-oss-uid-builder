# HMA-OSS-UID · Public Builder

Public, reproducible CI for **HMA-OSS-UID** (upstream HMA-OSS `oss-177` base + local scoped UID filtering).

This repository contains **no source code**. It only:
1. authenticates to the private source repo `CWIFISB/hma-oss-uid` with a fine-grained PAT stored as the `SOURCE_REPO_TOKEN` secret,
2. checks out the submodule, builds the manager APK + the Zygisk module,
3. publishes a signed GitHub Release with the artifacts.

## Why split private source / public builder
- Source stays private (UID engine, signing details).
- Build is public & reproducible: anyone can read exactly how the artifact was produced.
- The private repo is never exposed; only the resulting binaries are published.

## Required secrets
| Secret | Purpose |
|---|---|
| `SOURCE_REPO_TOKEN` | fine-grained PAT, **Contents: Read** on `CWIFISB/hma-oss-uid` |
| `KEY_STORE` | base64 of release `key.jks` |
| `KEY_STORE_PASSWORD` | keystore password |
| `ALIAS` | key alias |
| `ALIAS_KEY_PASSWORD` | key password |

## Trigger
- Push a tag `oss-*` in the private repo, or
- Run **Actions → Build → Run workflow** here (`workflow_dispatch`).

## Outputs
`zygote/build/outputs/magisk/release/*.zip` (module) and `app/build/outputs/apk/*/*.apk` (manager).
