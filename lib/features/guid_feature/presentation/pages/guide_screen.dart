import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/store_feature/business/entities/shop.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// In-app guide: policies and FAQ from [GET recycleorigin/v1/info] (managed in admin under Guide).
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  static const routeName = '/guideScreen';

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideSection {
  const _GuideSection({required this.title, required this.html});

  final String title;
  final String html;
}

class _GuideScreenState extends State<GuideScreen> {
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await context.read<CustomerInfoBloc>().fetchShopData();
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<_GuideSection> _sections(BuildContext context, Shop shop) {
    final l10n = context.l10n;
    return <_GuideSection>[
      _GuideSection(
        title: l10n.sectionReturnPolicyTitle,
        html: shop.return_policy,
      ),
      _GuideSection(title: l10n.sectionPrivacyTitle, html: shop.privacy),
      _GuideSection(
        title: l10n.sectionHowToOrderTitle,
        html: shop.how_to_order,
      ),
      _GuideSection(title: l10n.sectionFaqTitle, html: shop.faq),
      _GuideSection(
        title: l10n.sectionPaymentMethodsTitle,
        html: shop.pay_methods_desc,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final shop = context.watch<CustomerInfoBloc>().shop;

    return Scaffold(
      backgroundColor: context.appColors.cardBackground,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          context.l10n.guideTitle,
          style: TextStyle(
            color: context.appColors.scaffoldBackground,
            fontSize: textScale * 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Directionality(
        textDirection: Directionality.of(context),
        child: _buildBody(context, shop, textScale),
      ),
      drawer: mainDrawerIfRootRoute(context),
    );
  }

  Widget _buildBody(BuildContext context, Shop shop, double textScale) {
    if (_loading) {
      return Center(
        child: SpinKitFadingCircle(
          color: context.appColors.scaffoldBackground,
          size: 48,
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: context.appColors.subtitleColor,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.guideTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: context.appColors.subtitleColor,
                  fontSize: textScale * 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _load,
                icon: Icon(Icons.refresh_rounded),
                label: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final mediumLogo = shop.logo.sizes.medium.trim();
    final sections = _sections(context, shop);

    return RefreshIndicator(
      onRefresh: _load,
      color: context.appColors.scaffoldBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (mediumLogo.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    mediumLogo,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.storefront_rounded,
                      size: 64,
                      color: context.appColors.subtitleColor,
                    ),
                  ),
                ),
              )
            else
              Icon(
                Icons.recycling_rounded,
                size: 64,
                color: context.appColors.scaffoldBackground,
              ),
            const SizedBox(height: 16),
            Text(
              shop.name.isNotEmpty ? shop.name : context.l10n.guideTitle,
              style: TextStyle(
                color: context.colors.onSurface,
                fontFamily: 'BFarnaz',
                fontSize: textScale * 22,
              ),
              textAlign: TextAlign.center,
            ),
            if (shop.subject.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                shop.subject,
                style: TextStyle(
                  color: context.appColors.subtitleColor,
                  fontSize: textScale * 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ...sections.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    title: Text(
                      s.title,
                      style: TextStyle(
                        color: context.colors.onSurface,
                        fontSize: textScale * 15,
                      ),
                    ),
                    children: <Widget>[
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: s.html.trim().isEmpty
                              ? Text(
                                  '—',
                                  style: TextStyle(
                                    color: context.appColors.subtitleColor,
                                  ),
                                )
                              : HtmlWidget(
                                  s.html,
                                  textStyle: TextStyle(
                                    color: context.colors.onSurface,
                                    fontSize: textScale * 14,
                                    height: 1.45,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
