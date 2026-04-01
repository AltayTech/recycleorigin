import 'dart:ui' show Locale;

import 'package:flutter/material.dart';

import '../config/app_locale_controller.dart';
import '../widgets/main_drawer.dart';
import '../../l10n/l10n.dart';

/// App settings page (language).
class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.l10n.settingsTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: const MainDrawer(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.instance.localeNotifier,
          builder: (context, locale, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.languageTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: locale.languageCode,
                  decoration: InputDecoration(
                    labelText: context.l10n.applicationLanguageLabel,
                  ),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'en',
                      child: Text(context.l10n.englishLabel),
                    ),
                    DropdownMenuItem<String>(
                      value: 'tr',
                      child: Text(context.l10n.turkishLabel),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    AppLocaleController.instance.setLocaleCode(value);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

