import 'dart:ui' show Locale;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/config/app_config.dart';
import 'package:recycleorigin/core/config/app_locale_controller.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigin/features/articles_feature/presentation/bloc/articles_bloc.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/pages/clear_screen.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_bloc.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_repository.dart';
import 'package:recycleorigin/features/support_tickets/presentation/cubit/support_tickets_list_cubit.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_ticket_create_screen.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_ticket_detail_screen.dart';
import 'package:recycleorigin/features/support_tickets/presentation/screens/support_tickets_list_screen.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/orders_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/pages/wallet_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_detail_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigin/features/waste_feature/presentation/wastes_screen_animated_list.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';
import 'package:recycleorigin/l10n/l10n.dart';

import 'core/screens/splash_Screen.dart';
import 'core/screens/settings_screen.dart';
import 'core/utils/app_info_service.dart';
import 'features/about_feature/presentation/pages/about_us_screen.dart';
import 'features/articles_feature/presentation/pages/article_detail_screen.dart';
import 'features/articles_feature/presentation/pages/article_screen.dart';
import 'features/collect_feature/presentation/pages/waste_cart_screen.dart';
import 'features/contac_us_feature/presentation/pages/contact_with_us_screen.dart';
import 'features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'features/customer_feature/presentation/screens/customer_detail_info_edit_screen.dart';
import 'features/customer_feature/presentation/screens/customer_notification_screen.dart';
import 'features/customer_feature/presentation/screens/customer_orders_screen.dart';
import 'features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'features/auth_feature/presentation/screens/login_screen.dart';
import 'features/customer_feature/presentation/screens/profile_screen.dart';
import 'features/guid_feature/presentation/pages/guide_screen.dart';
import 'features/home_feature/presentation/home_screen.dart';
import 'features/meassage_feature/presentation/pages/message_detail_screen.dart';
import 'features/meassage_feature/presentation/pages/messages_create_reply_screen.dart';
import 'features/meassage_feature/presentation/pages/messages_create_screen.dart';
import 'features/meassage_feature/presentation/pages/messages_screen.dart';
import 'features/store_feature/presentation/screens/cart_screen.dart';
import 'features/store_feature/presentation/screens/order_products_send_screen.dart';
import 'features/store_feature/presentation/screens/order_view_screen.dart';
import 'features/store_feature/presentation/screens/product_detail_screen.dart';
import 'features/store_feature/presentation/screens/product_screen.dart';
import 'features/waste_feature/collect_list_screen.dart';
import 'features/waste_feature/presentation/address_screen.dart';
import 'features/waste_feature/presentation/pages/map_screen.dart';
import 'features/waste_feature/presentation/waste_request_date_screen.dart';
import 'features/waste_feature/presentation/waste_request_send_screen.dart';
import 'features/waste_feature/presentation/wastes_screen.dart';

/// Bootstraps the customer app and required platform services.
///
/// Startup steps:
/// 1. Lock orientation to portrait.
/// 2. Load environment-based app configuration.
/// 3. Warm up app metadata service.
/// 4. Launch the root widget tree.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app configuration (loads environment variables)
  await AppConfig.initialize();

  // Initialize app info service early for better performance
  await AppInfoService.instance.initialize();

  await AppLocaleController.instance.load();

  runApp(const MyApp());
}

/// Root widget that wires blocs, localization, theme, and routes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsBloc>(
          create: (_) => ProductsBloc(apiClient),
          lazy: false,
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(apiClient),
        ),
        BlocProvider<CustomerInfoBloc>(
          create: (_) => CustomerInfoBloc(apiClient),
        ),
        BlocProvider<MessagesBloc>(
          create: (_) => MessagesBloc(),
        ),
        BlocProvider<SupportTicketsListCubit>(
          create: (_) => SupportTicketsListCubit(SupportTicketRepository(
            ApiClient(),
          )),
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
            theme: ThemeData(
              primarySwatch: Colors.green,
              // accentColor: Colors.amber,
              textTheme: ThemeData.light().textTheme.copyWith(
                    bodyLarge: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color.fromRGBO(20, 51, 51, 1),
                    ),
                    bodyMedium: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color.fromRGBO(20, 51, 51, 1),
                    ),
                    displayLarge: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            home: SplashScreens(),
            routes: {
              NavigationBottomScreen.routeName: (ctx) => NavigationBottomScreen(),
              HomeScreen.routeName: (ctx) => HomeScreen(),
              WasteCartScreen.routeName: (ctx) => WasteCartScreen(),
              WastesScreen.routeName: (ctx) => WastesScreen(),
              ProfileScreen.routeName: (ctx) => ProfileScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              ProductsScreen.routeName: (ctx) => ProductsScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrderProductsSendScreen.routeName: (ctx) => OrderProductsSendScreen(),
              OrderViewScreen.routeName: (ctx) => OrderViewScreen(),
              AboutUsScreen.routeName: (ctx) => AboutUsScreen(),
              ContactWithUs.routeName: (ctx) => ContactWithUs(),
              SettingsScreen.routeName: (ctx) => const SettingsScreen(),
              CustomerDetailInfoEditScreen.routeName: (ctx) =>
                  CustomerDetailInfoEditScreen(),
              CustomerOrdersScreen.routeName: (ctx) => CustomerOrdersScreen(),
              CustomerUserInfoScreen.routeName: (ctx) => CustomerUserInfoScreen(),
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
              WasteRequestDateScreen.routeName: (ctx) => WasteRequestDateScreen(),
              WasteRequestSendScreen.routeName: (ctx) => WasteRequestSendScreen(),
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
