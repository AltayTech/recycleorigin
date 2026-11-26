import 'package:material_ui/material_ui.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';

/// Localization delegates for every `MaterialApp` in the app and in tests.
///
/// The generated `AppLocalizations.localizationsDelegates` still uses the
/// deprecated `flutter_localizations` delegates (gen-l10n has not caught up
/// with the move to `material_ui`). Use this list instead: it pairs the app's
/// own delegate with the `material_ui` delegates for Widgets, Material and
/// Cupertino.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ];
