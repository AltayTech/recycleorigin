import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tamizshahr/provider/charities.dart';
import 'package:tamizshahr/provider/clearings.dart';
import 'package:tamizshahr/provider/orders.dart';
import 'package:tamizshahr/screens/charity_detail_screen.dart';
import 'package:tamizshahr/screens/charity_screen.dart';
import 'package:tamizshahr/screens/clear_screen.dart';
import 'package:tamizshahr/screens/collect_detail_screen.dart';
import 'package:tamizshahr/screens/donation_screen.dart';
import 'package:tamizshahr/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:tamizshahr/screens/wallet_screen.dart';
import 'package:tamizshahr/features/waste_feature/presentation/wastes_screen_animated_list.dart';

import './provider/articles.dart';
import 'features/customer_feature/presentation/providers/auth.dart';
import './provider/messages.dart';
import 'features/waste_feature/presentation/providers/wastes.dart';
import './screens/about_us_screen.dart';
import 'features/waste_feature/presentation/address_screen.dart';
import './screens/article_detail_screen.dart';
import './screens/article_screen.dart';
import 'features/store_feature/presentation/screens/cart_screen.dart';
import './screens/contact_with_us_screen.dart';
import 'features/customer_feature/presentation/screens/customer_notification_screen.dart';
import 'features/customer_feature/presentation/screens/customer_orders_screen.dart';
import 'features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'features/home_feature/presentation/home_screen.dart';
import './screens/map_screen.dart';
import './screens/messages_create_screen.dart';
import 'core/screens/navigation_bottom_screen.dart';
import 'features/store_feature/presentation/screens/order_products_send_screen.dart';
import 'features/waste_feature/presentation/waste_cart_screen.dart';
import 'features/waste_feature/presentation/waste_request_date_screen.dart';
import 'features/waste_feature/presentation/waste_request_send_screen.dart';
import 'features/waste_feature/presentation/wastes_screen.dart';
import 'core/constants/strings.dart';
import 'provider/Products.dart';
import 'features/customer_feature/presentation/providers/customer_info.dart';
import 'screens/collect_list_screen.dart';
import 'features/customer_feature/presentation/screens/customer_detail_info_edit_screen.dart';
import 'features/customer_feature/presentation/screens/login_screen.dart';
import 'features/customer_feature/presentation/screens/profile_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/message_detail_screen.dart';
import 'screens/messages_create_reply_screen.dart';
import 'screens/messages_screen.dart';
import 'features/store_feature/presentation/screens/order_view_screen.dart';
import 'features/store_feature/presentation/screens/product_detail_screen.dart';
import 'features/store_feature/presentation/screens/product_screen.dart';
import 'core/screens/splash_Screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Products(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerInfo(),
        ),
        ChangeNotifierProvider(
          create: (context) => Messages(),
        ),
        ChangeNotifierProvider(
          create: (context) => Wastes(),
        ),
        ChangeNotifierProvider(
          create: (context) => Articles(),
        ),
        ChangeNotifierProvider(
          create: (context) => Charities(),
        ),
        ChangeNotifierProvider(
          create: (context) => Orders(),
        ),
        ChangeNotifierProvider(
          create: (context) => Clearings(),
        ),
      ],
      child: MaterialApp(
        title: Strings.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.green,
          // accentColor: Colors.amber,
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyLarge: TextStyle(
                  fontFamily: 'Iransans',
                  color: Color.fromRGBO(20, 51, 51, 1),
                ),
                bodyMedium: TextStyle(
                  fontFamily: 'Iransans',
                  color: Color.fromRGBO(20, 51, 51, 1),
                ),
                displayLarge: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Iransans',
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Directionality(
          child: SplashScreens(),
          textDirection: TextDirection.rtl, // setting rtl
        ),
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
          CustomerDetailInfoEditScreen.routeName: (ctx) =>
              CustomerDetailInfoEditScreen(),
          CustomerOrdersScreen.routeName: (ctx) => CustomerOrdersScreen(),
          CustomerUserInfoScreen.routeName: (ctx) => CustomerUserInfoScreen(),
          CustomerNotificationScreen.routeName: (ctx) =>
              CustomerNotificationScreen(),
          GuideScreen.routeName: (ctx) => GuideScreen(),
          MessageScreen.routeName: (ctx) => MessageScreen(),
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
          CharityScreen.routeName: (ctx) => CharityScreen(),
          CharityDetailScreen.routeName: (ctx) => CharityDetailScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          CollectDetailScreen.routeName: (ctx) => CollectDetailScreen(),
          DonationScreen.routeName: (ctx) => DonationScreen(),
          WastesScreenAnimatedList.routeName: (ctx) =>
              WastesScreenAnimatedList(),
          ClearScreen.routeName: (ctx) => ClearScreen(),
        },
      ),
    );
  }
}
