import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/home_feature/presentation/home_screen.dart';
import 'package:recycleorigin/recycle_origin_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/mock_api_client.dart';

/// Device / emulator integration: verifies the real app shell boots with
/// injected API and reaches the home surface without the splash delay.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Customer app bootstrap', () {
    setUpAll(() async {
      await AppConfig.initialize();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    testWidgets('RecycleOriginApp shows home content', (tester) async {
      final mock = MockApiClient();
      mock.setGetResponse(
        'pasmands/v1/products/category',
        Success<List<dynamic>>(<dynamic>[]),
      );

      await tester.pumpWidget(
        RecycleOriginApp(
          apiClient: mock,
          home: const HomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('Wallet'), findsOneWidget);
    });
  });
}
