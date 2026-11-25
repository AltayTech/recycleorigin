import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:recycleorigin/app_bootstrap.dart';

/// Bootstraps the customer app and required platform services.
///
/// The env file is chosen, in order, from:
/// 1. `--dart-define=FLUTTER_ENV=dev|staging|prod`
/// 2. the Android/iOS build flavor (`--flavor prod` → `.env.prod`)
/// 3. the build mode (release → prod, debug/profile → dev)
///
/// Each flavor bundles only its own env file (see pubspec.yaml), so a release
/// build can never silently fall back to the dev configuration.
void main() async {
  await bootstrapApp(envFileFor(resolveEnvironment()));
}

/// Resolves the active environment name (see [main] for the precedence).
String resolveEnvironment() {
  const fromDefine = String.fromEnvironment('FLUTTER_ENV');
  if (fromDefine.isNotEmpty) {
    return fromDefine;
  }
  final flavor = appFlavor;
  if (flavor != null && flavor.isNotEmpty) {
    return flavor;
  }
  return kReleaseMode ? 'prod' : 'dev';
}

/// Maps an environment/flavor name to its bundled env asset.
String envFileFor(String environment) {
  switch (environment.trim().toLowerCase()) {
    case 'dev':
    case 'development':
      return 'assets/env/.env.dev';
    case 'staging':
      return 'assets/env/.env.staging';
    default:
      return 'assets/env/.env.prod';
  }
}
