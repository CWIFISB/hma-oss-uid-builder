# HMA-OSS-UID · Public Builder

Public, reproducible CI for **HMA-OSS-UID** (upstream HMA-OSS `oss-177` base +
local scoped ARM64 UID filtering).

This repository contains **no source code**. It only:

1. authenticates to the private source repo `CWIFISB/hma-oss-uid` with a
   fine-grained PAT stored as the `SOURCE_REPO_TOKEN` secret,
2. builds the manager signature-migration payload and runs the host unit tests,
3. checks out the submodule and builds the manager APK + the Zygisk module,
4. post-processes the Gradle module zip into the ARM64-only release package,
5. publishes a signed GitHub Release with the artifacts.

## Build chain

```
tools/prepare_migration.sh   javac + d8 on HmaManagerMigration.java  -> helper.dex
                             keytool -exportcert on key.jks           -> manager-cert.der
tools/run_tests.sh           g++ build + run of uid-native/tests (policy/notification)
./gradlew :app:assemble      manager APK
./gradlew :zygote:assemble   ZygoteLoader module zip (payloads only)
tools/finalize_module.py     overlay publication/module-template, inject migration/,
                             regenerate customize.d/00-verify-resources.sh
```

`finalize_module.py` is what makes the artifact differ from a plain ZygoteLoader
output: the installer becomes ARM64-only (`30-place-libraries.sh` aborts on any
other ABI), the manager install goes through the backup/rollback migration path
(`35-install-manager-app.sh` + `migration/`), and every shipped file carries a
SHA-256 entry checked before install.

## Why split private source / public builder

- Source stays private (UID engine, signing details).
- Build is public & reproducible: anyone can read exactly how the artifact was
  produced.
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

- `zygote/build/outputs/magisk/release/HMA-OSS-ZYGISK-oss-177-uid.N-release.zip`
  — the flashable module (ARM64 only).
- `app/build/outputs/apk/release/*.apk` — the manager APK.

## Install-time behaviour of the module

| File | Effect |
|---|---|
| `customize.d/11-enforce-arch.sh` | rejects non-ARM devices up front |
| `customize.d/30-place-libraries.sh` | aborts unless `$ARCH = arm64` |
| `customize.d/35-install-manager-app.sh` | sources `migration/manager-migration.sh`, backs up the existing manager APK + app data, uninstalls, installs, restores, verifies the certificate, rolls back on any failure |
| `customize.d/00-verify-resources.sh` | SHA-256 gate over every file above |
| `migration/restore-previous.sh` | manual rollback entry point left in `/data/adb/hma_oss_manager_backup/<stamp>/` |