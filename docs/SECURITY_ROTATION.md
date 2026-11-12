# Release-key rotation and history purge (customer app)

Findings from the 2026 review: the Play **release keystore**
(`android/app/recycleorigin-release-key.keystore`) and `android/key.properties`
(containing the passwords) were committed in `6170647` and removed in
`00f8134`; they remain in history. A local stash also holds the keystore and
`assets/env/.env.prod`.

## 1. Rotate (do this first)

1. If the app uses **Play App Signing**, the committed key is only the *upload*
   key: Play Console -> Setup -> App signing -> *Request upload key reset*,
   then generate a new keystore and keep it outside the repo
   (see `recycle-origin-secrets/recycleorigin/`).
2. If Play App Signing is **not** enabled, the leaked key is the app signing
   key and cannot be replaced for existing installs - enable Play App Signing
   and plan a migration.
3. Rotate anything that was in `assets/env/.env.prod`.

## 2. Purge history (run by a maintainer)

```bash
git clone --mirror . ../recycleorigin-mirror.git   # safety backup
git stash clear
git filter-repo --invert-paths \
  --path android/key.properties \
  --path android/app/recycleorigin-release-key.keystore
git remote add origin https://github.com/AltayTech/recycleorigin.git
git push --force --all origin && git push --force --tags origin
```

## 3. Stop tracking generated files

```bash
git rm -r --cached android/build ios/Flutter/ephemeral
git commit -m "chore: stop tracking generated files"
```

(`.gitignore` already lists both paths.)

## Release builds

`android/app/build.gradle` now **fails** `assemble*Release` / `bundle*Release`
when `android/key.properties` is missing, instead of silently signing with the
debug key. Create it from `key.properties.example`.
