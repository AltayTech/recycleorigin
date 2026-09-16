# RecycleOrigin (customer app)

Flutter app for **recyclable pickup requests**, **wallet payout requests**, and
**support tickets**. English and Turkish.

The in-app **Store** tab is shipped as Coming Soon (`ENABLE_STORE=false`). There
is no payment gateway.

## What it does

- Register / sign in (email + Google where Firebase is configured)
- Complete profile and addresses
- Request a waste pickup
- View wallet history and submit a **staff-handled payout request** (not an instant bank transfer)
- Open support tickets
- Read the in-app Guide (privacy / FAQ from the API)

## What it does not do (yet)

- Store checkout or payments
- Articles
- Charity donations
- SMS login (API returns 501)
- Google Maps (pickup map uses OSM / geolocator)
- WebSockets

## Run locally

```bash
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

API base URL and flags live in `assets/env/.env.dev` (synced from
`recycle-origin-secrets/`, not invented in git).

## Quality checks

```bash
dart format lib test
flutter analyze --no-fatal-infos
flutter test
```

## Project layout

```
lib/
├── core/                 # config, theme, networking, shared widgets
├── features/
│   ├── home_feature/
│   ├── waste_feature/    # pickup cart and request
│   ├── store_feature/    # kept in tree; gated Coming Soon
│   ├── customer_feature/
│   ├── wallet_feature/
│   └── ...
└── l10n/
```
