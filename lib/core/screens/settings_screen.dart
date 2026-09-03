import 'package:flutter/material.dart';

import '../config/app_locale_controller.dart';
import '../config/app_theme_controller.dart';
import '../theme/theme_context_extensions.dart';
import '../utils/app_info_service.dart';
import '../widgets/drawer_or_back_leading.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';

/// Application settings: language preference and read-only app metadata.
class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final appColors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.instance.localeNotifier,
        builder: (context, locale, _) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: AppThemeController.instance.themeModeNotifier,
            builder: (context, themeMode, __) {
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.settingsScreenIntro,
                      style: context.texts.bodyMedium?.copyWith(
                        color: appColors.subtitleColor,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SettingsSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: l10n.appearanceTitle,
                            icon: Icons.palette_outlined,
                            iconColor: colors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.appearanceLabel,
                            style: context.texts.labelLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            children: [
                              _OptionTile(
                                selected: themeMode == ThemeMode.system,
                                title: l10n.themeSystemLabel,
                                onTap: () => AppThemeController.instance
                                    .setThemeMode(ThemeMode.system),
                              ),
                              Divider(height: 1, color: appColors.divider),
                              _OptionTile(
                                selected: themeMode == ThemeMode.light,
                                title: l10n.themeLightLabel,
                                onTap: () => AppThemeController.instance
                                    .setThemeMode(ThemeMode.light),
                              ),
                              Divider(height: 1, color: appColors.divider),
                              _OptionTile(
                                selected: themeMode == ThemeMode.dark,
                                title: l10n.themeDarkLabel,
                                onTap: () => AppThemeController.instance
                                    .setThemeMode(ThemeMode.dark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: l10n.languageTitle,
                            icon: Icons.translate_rounded,
                            iconColor: colors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.applicationLanguageLabel,
                            style: context.texts.labelLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Semantics(
                            label: l10n.applicationLanguageLabel,
                            child: Column(
                              children: [
                                _OptionTile(
                                  selected: locale.languageCode == 'en',
                                  title: l10n.englishLabel,
                                  onTap: () => AppLocaleController.instance
                                      .setLocaleCode('en'),
                                ),
                                Divider(height: 1, color: appColors.divider),
                                _OptionTile(
                                  selected: locale.languageCode == 'tr',
                                  title: l10n.turkishLabel,
                                  onTap: () => AppLocaleController.instance
                                      .setLocaleCode('tr'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: l10n.appInformationSectionTitle,
                            icon: Icons.info_outline_rounded,
                            iconColor: colors.primary,
                          ),
                          const SizedBox(height: 16),
                          _AppMetaBlock(l10n: l10n),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.appColors.cardBackground,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: context.colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        button: true,
        selected: selected,
        label: title,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? context.colors.primary
                      : context.appColors.subtitleColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppMetaBlock extends StatelessWidget {
  const _AppMetaBlock({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final info = AppInfoService.instance;
    final name = info.appName;
    final versionLine = '${l10n.version} ${info.fullVersion}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            color: context.colors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          versionLine,
          style: context.texts.bodySmall?.copyWith(
            color: context.appColors.subtitleColor,
          ),
        ),
      ],
    );
  }
}
