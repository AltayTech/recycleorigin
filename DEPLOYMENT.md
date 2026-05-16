# RecycleOrigin Customer App Deployment

This guide covers both **dev** and **prod** runs for the customer app.

## Secrets (local development)

Environment files, keystores, Firebase keys, and TLS material are **not**
committed in this monorepo. They live in the private sibling repository
`recycle-origin-secrets/` inside this workspace (private Git repo; not the
`recycleorigin/` app repo).

From the monorepo root, after cloning that repo:

```powershell
pwsh scripts/secrets/sync-secrets.ps1 -Pull
```

On macOS/Linux:

```bash
./scripts/secrets/sync-secrets.sh --pull
```

Override the default path with `RECYCLE_ORIGIN_SECRETS_DIR` if needed.
**CI** must use platform secrets (for example GitHub Actions encrypted
secrets), not the sibling repo or these sync scripts.

If the script reports a **blocked** copy (file locked), close editors or
processes using that path and run it again.

## 1) Environment mapping

- `dev` entrypoint: `lib/main_dev.dart` -> `assets/env/.env.dev`
- `staging` entrypoint: `lib/main_staging.dart` -> `assets/env/.env.staging`
- `prod` entrypoint: `lib/main_prod.dart` -> `assets/env/.env.prod`

Current production backend:
- `API_BASE_URL=https://api.app.recycleorigin.xyz/`

## 2) Dev mode (local run)

```bash
cd recycleorigin
flutter pub get
flutter run -t lib/main_dev.dart
```

## 3) Prod mode (local smoke run)

Use this before creating release artifacts.

```bash
cd recycleorigin
flutter pub get
flutter run --release -t lib/main_prod.dart
```

## 4) Production artifacts

### Android AAB

```bash
cd recycleorigin
flutter pub get
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Output:
- `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

### iOS IPA

```bash
cd recycleorigin
flutter pub get
flutter build ipa --release --flavor prod -t lib/main_prod.dart
```

## 5) Update flow

```bash
cd recycleorigin
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Upload artifact to Play Console / App Store Connect.

## 6) Rollback

- Promote previous approved release from store console.
- Keep previous signed `.aab` / `.ipa` artifacts for quick rollback.

## 7) Production verification checklist

- [ ] App launches and login works.
- [ ] Customer profile loads and updates successfully.
- [ ] Create collect/request flow works end-to-end.
- [ ] Messages/tickets screen works.
- [ ] No API calls target localhost or dev URLs.

Quick backend check:

```bash
curl -fsS https://api.app.recycleorigin.xyz/healthz
```

## 8) Config reference

| Variable | Required | Description |
|---|---|---|
| `ENVIRONMENT` | Yes | `development`, `staging`, `production`. |
| `API_BASE_URL` | Yes | Backend base URL (root, trailing slash recommended). |
| `API_ROOT_URL` | No | Optional REST root override. |
| `GOOGLE_MAPS_API_KEY` | No | Maps SDK key. |
