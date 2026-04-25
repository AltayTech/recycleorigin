# RecycleOrigin Customer App Deployment Guide

## 1) Initial setup

### Prerequisites
- Flutter SDK installed.
- Android Studio / Xcode configured for signing.
- Backend environment already deployed.

### Flavor setup
- `dev`: uses `lib/main_dev.dart` and `assets/env/.env.dev`
- `staging`: uses `lib/main_staging.dart` and `assets/env/.env.staging`
- `prod`: uses `lib/main_prod.dart` and `assets/env/.env.prod`

Android flavors are configured in `android/app/build.gradle`.
iOS flavor config files are scaffolded under `ios/Flutter/`.

## 2) How to deploy

### Production Android build
```bash
cd recycleorigin
flutter pub get
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

### Production iOS build
```bash
cd recycleorigin
flutter pub get
flutter build ipa --release --flavor prod -t lib/main_prod.dart
```

### Staging build (when enabled)
```bash
flutter build apk --release --flavor staging -t lib/main_staging.dart
```

## 3) How to update

```bash
cd recycleorigin
git pull --ff-only
flutter pub get
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Upload the new bundle to Play Console / App Store Connect.

## 4) Rollback procedure

- Keep previous signed artifacts (`.aab`, `.ipa`) in release storage.
- Rollback by resubmitting or promoting the previous approved release in store
  consoles.
- For emergency backend compatibility issues, temporarily point clients to a
  compatible backend via next patch release flavor env files.

## 5) Staging TODO checklist

- [ ] Add staging app IDs and signing identities.
- [ ] Create iOS staging scheme tied to `Staging.xcconfig`.
- [ ] Add `google-services.json` and `GoogleService-Info.plist` for staging.
- [ ] Build and distribute with `--flavor staging -t lib/main_staging.dart`.

## 6) Environment variable reference

| Variable | Required | Description |
|---|---|---|
| `ENVIRONMENT` | Yes | App runtime environment tag. |
| `API_BASE_URL` | Yes | Backend base URL (must match target backend environment). |
| `API_ROOT_URL` | No | Optional explicit REST root URL override. |
| `GOOGLE_MAPS_API_KEY` | No | Maps SDK key for map-related features. |
