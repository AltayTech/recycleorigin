import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/home_feature/presentation/home_screen.dart';
import 'package:recycleorigin/recycle_origin_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/mock_api_client.dart';

/// Cross-feature smoke flows against the real widget tree (mocked HTTP).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User flows (integration)', () {
    setUpAll(() async {
      await AppConfig.initialize();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    testWidgets('home displays core services', (tester) async {
      final mock = MockApiClient();
      mock.setGetResponse(
        'recycleorigin/v1/products/category',
        Success<List<dynamic>>(<dynamic>[]),
      );

      await tester.pumpWidget(
        RecycleOriginApp(apiClient: mock, home: const HomeScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Store'), findsOneWidget);
      expect(find.text('Articles'), findsOneWidget);
    });

    testWidgets('tapping Wallet navigates toward wallet route', (tester) async {
      final mock = MockApiClient();
      mock.setGetResponse(
        'recycleorigin/v1/products/category',
        Success<List<dynamic>>(<dynamic>[]),
      );

      await tester.pumpWidget(
        RecycleOriginApp(apiClient: mock, home: const HomeScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      await tester.tap(find.text('Wallet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    });
  });
}
