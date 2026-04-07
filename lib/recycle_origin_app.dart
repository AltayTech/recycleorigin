import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigin/core/config/app_locale_controller.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigin/core/screens/settings_screen.dart';
import 'package:recycleorigin/core/screens/splash_Screen.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/features/about_feature/presentation/pages/about_us_screen.dart';
import 'package:recycleorigin/features/articles_feature/presentation/bloc/articles_bloc.dart';
import 'package:recycleorigin/features/articles_feature/presentation/pages/article_detail_screen.dart';
import 'package:recycleorigin/features/articles_feature/presentation/pages/article_screen.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/pages/clear_screen.dart';
import 'package:recycleorigin/features/collect_feature/presentation/pages/waste_cart_screen.dart';
import 'package:recycleorigin/features/contac_us_feature/presentation/pages/contact_with_us_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/customer_detail_info_edit_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/customer_notification_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/customer_orders_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'package:recycleorigin/features/customer_feature/presentation/screens/profile_screen.dart';
import 'package:recycleorigin/features/guid_feature/presentation/pages/guide_screen.dart';
import 'package:recycleorigin/features/home_feature/presentation/home_screen.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_bloc.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/pages/message_detail_screen.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/pages/messages_create_reply_screen.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/pages/messages_create_screen.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/pages/messages_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/orders_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/cart_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/order_products_send_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/order_view_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/product_detail_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/product_screen.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_repository.dart';
import 'package:recycleorigin/features/support_tickets/presentation/cubit/support_tickets_list_cubit.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_ticket_create_screen.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_ticket_detail_screen.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_tickets_list_screen.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/pages/wallet_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_detail_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_list_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/address_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigin/features/waste_feature/presentation/pages/map_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/waste_request_date_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/waste_request_send_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/wastes_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/wastes_screen_animated_list.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Root widget: blocs, localization, theme, and named routes.
///
/// Pass [apiClient] in tests to inject a mock. Pass [home] to skip splash
/// (e.g. integration or widget tests).
class RecycleOriginApp extends StatelessWidget {
  RecycleOriginApp({
    super.key,
    ApiClient? apiClient,
    this.home,
  }) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsBloc>(
          create: (_) => ProductsBloc(_apiClient),
          lazy: false,
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(_apiClient),
        ),
        BlocProvider<CustomerInfoBloc>(
          create: (_) => CustomerInfoBloc(_apiClient),
        ),
        BlocProvider<MessagesBloc>(
          create: (_) => MessagesBloc(),
        ),
        BlocProvider<SupportTicketsListCubit>(
          create: (_) => SupportTicketsListCubit(
            SupportTicketRepository(_apiClient),
          ),
        ),
        BlocProvider<WastesBloc>(
          create: (_) => WastesBloc(),
        ),
        BlocProvider<ArticlesBloc>(
          create: (_) => ArticlesBloc(),
        ),
        BlocProvider<OrdersBloc>(
          create: (_) => OrdersBloc(),
        ),
        BlocProvider<ClearingsBloc>(
          create: (_) => ClearingsBloc(),
        ),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.instance.localeNotifier,
        builder: (context, locale, _) {
          return MaterialApp(
            onGenerateTitle: (context) => context.l10n.recycleorigin,
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme(),
            home: home ?? const SplashScreens(),
            routes: {
              NavigationBottomScreen.routeName: (ctx) =>
                  NavigationBottomScreen(),
              HomeScreen.routeName: (ctx) => HomeScreen(),
              WasteCartScreen.routeName: (ctx) => WasteCartScreen(),
              WastesScreen.routeName: (ctx) => WastesScreen(),
              ProfileScreen.routeName: (ctx) => ProfileScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              ProductsScreen.routeName: (ctx) => ProductsScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrderProductsSendScreen.routeName: (ctx) =>
                  OrderProductsSendScreen(),
              OrderViewScreen.routeName: (ctx) => OrderViewScreen(),
              AboutUsScreen.routeName: (ctx) => AboutUsScreen(),
              ContactWithUs.routeName: (ctx) => ContactWithUs(),
              SettingsScreen.routeName: (ctx) => const SettingsScreen(),
              CustomerDetailInfoEditScreen.routeName: (ctx) =>
                  CustomerDetailInfoEditScreen(),
              CustomerOrdersScreen.routeName: (ctx) => CustomerOrdersScreen(),
              CustomerUserInfoScreen.routeName: (ctx) =>
                  CustomerUserInfoScreen(),
              CustomerNotificationScreen.routeName: (ctx) =>
                  CustomerNotificationScreen(),
              GuideScreen.routeName: (ctx) => GuideScreen(),
              MessageScreen.routeName: (ctx) => MessageScreen(),
              SupportTicketsListScreen.routeName: (ctx) =>
                  const SupportTicketsListScreen(),
              SupportTicketCreateScreen.routeName: (ctx) =>
                  const SupportTicketCreateScreen(),
              SupportTicketDetailScreen.routeName: (ctx) =>
                  const SupportTicketDetailScreen(),
              MessageCreateScreen.routeName: (ctx) => MessageCreateScreen(),
              MessageCreateReplyScreen.routeName: (ctx) =>
                  MessageCreateReplyScreen(),
              MessageDetailScreen.routeName: (ctx) => MessageDetailScreen(),
              MapScreen.routeName: (ctx) => MapScreen(),
              AddressScreen.routeName: (ctx) => AddressScreen(),
              ArticlesScreen.routeName: (ctx) => ArticlesScreen(),
              ArticleDetailScreen.routeName: (ctx) => ArticleDetailScreen(),
              WasteRequestDateScreen.routeName: (ctx) =>
                  WasteRequestDateScreen(),
              WasteRequestSendScreen.routeName: (ctx) =>
                  WasteRequestSendScreen(),
              CollectListScreen.routeName: (ctx) => CollectListScreen(),
              WalletScreen.routeName: (ctx) => WalletScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              CollectDetailScreen.routeName: (ctx) => CollectDetailScreen(),
              WastesScreenAnimatedList.routeName: (ctx) =>
                  WastesScreenAnimatedList(),
              ClearScreen.routeName: (ctx) => ClearScreen(),
            },
          );
        },
      ),
    );
  }
}
