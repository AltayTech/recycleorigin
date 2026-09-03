import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/home_feature/presentation/widgets/home_explore_row.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('HomeExploreRow invokes guide tap', (tester) async {
    var guideTapped = false;

    await tester.pumpWidget(
      wrap(HomeExploreRow(onGuideTap: () => guideTapped = true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guide'));
    expect(guideTapped, isTrue);
  });
}
