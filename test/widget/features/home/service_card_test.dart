import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/home_feature/presentation/widgets/service_card.dart';

void main() {
  testWidgets('ServiceCard invokes onTap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          body: Center(
            child: ServiceCard(
              title: 'Test service',
              icon: Icons.recycling,
              color: const Color(0xFF22C55E),
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ServiceCard));
    expect(tapped, isTrue);
  });

  testWidgets('ServiceCard shows title text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          body: ServiceCard(
            title: 'Articles',
            icon: Icons.article_outlined,
            color: const Color(0xFFF59E0B),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Articles'), findsOneWidget);
  });
}
