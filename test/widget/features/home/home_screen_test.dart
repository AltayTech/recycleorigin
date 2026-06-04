import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/home_feature/presentation/home_screen.dart';
import 'package:recycleorigin/recycle_origin_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    testWidgets('renders localized Wallet service card', (tester) async {
      final mock = MockApiClient();
      mock.setGetResponse(
        'recycleorigin/v1/products/category',
        Success<List<dynamic>>(<dynamic>[]),
      );

      await tester.pumpWidget(
        RecycleOriginApp(
          apiClient: mock,
          home: const HomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Wallet'), findsOneWidget);
    });
  });
}
