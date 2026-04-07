// Suites live under:
// - test/unit/ — blocs, cubits, services, validators
// - test/widget/ — widgets and screens (mocked IO)
// - integration_test/ — full app on device: flutter test integration_test -d <deviceId>

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flutter_test binding is available', () {
    expect(TestWidgetsFlutterBinding.ensureInitialized(), isNotNull);
  });
}
