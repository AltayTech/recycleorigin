import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/widgets/shell_app_bar.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';

void main() {
  Future<void> pumpShellAppBar(
    WidgetTester tester, {
    required ThemeData theme,
    required String title,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: ShellAppBar(title: title),
          body: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ShellAppBar uses light theme app bar foreground', (
    tester,
  ) async {
    final theme = AppTheme.lightTheme();
    await pumpShellAppBar(tester, theme: theme, title: 'RecycleOrigin');

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.foregroundColor, theme.appBarTheme.foregroundColor);
    expect(find.text('RecycleOrigin'), findsOneWidget);
  });

  testWidgets('ShellAppBar uses dark theme app bar foreground', (tester) async {
    final theme = AppTheme.darkTheme();
    await pumpShellAppBar(tester, theme: theme, title: 'RecycleOrigin');

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.foregroundColor, theme.appBarTheme.foregroundColor);
    expect(find.text('RecycleOrigin'), findsOneWidget);
  });

  testWidgets('NavigationBar label colors differ for light and dark', (
    tester,
  ) async {
    final lightNav = AppTheme.lightTheme().navigationBarTheme;
    final darkNav = AppTheme.darkTheme().navigationBarTheme;

    expect(lightNav.backgroundColor, isNot(darkNav.backgroundColor));
    expect(
      lightNav.labelTextStyle?.resolve(<WidgetState>{}),
      isNot(darkNav.labelTextStyle?.resolve(<WidgetState>{})),
    );
  });
}
