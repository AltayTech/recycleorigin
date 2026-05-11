import 'package:recycleorigin/app_bootstrap.dart';

/// Bootstraps the customer app and required platform services.
///
/// Startup steps:
/// 1. Lock orientation to portrait.
/// 2. Load environment-based app configuration.
/// 3. Warm up app metadata service.
/// 4. Launch the root widget tree.
void main() async {
  await bootstrapApp('assets/env/.env.dev');
}
