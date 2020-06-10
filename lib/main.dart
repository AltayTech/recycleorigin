import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamizshahr/provider/articles.dart';
import 'package:tamizshahr/screens/address_screen.dart';
import 'package:tamizshahr/screens/article_detail_screen.dart';
import 'package:tamizshahr/screens/article_screen.dart';
import 'package:tamizshahr/screens/map_screen.dart';
import 'package:tamizshahr/screens/waste_request_date_screen.dart';
import 'package:tamizshahr/screens/waste_request_send_screen.dart';
import 'package:tamizshahr/screens/wastes_screen.dart';

import './provider/auth.dart';
import './provider/messages.dart';
import './provider/wastes.dart';
import './screens/about_us_screen.dart';
import './screens/cart_screen.dart';
import './screens/cash_payment_screen.dart';
import './screens/contact_with_us_screen.dart';
import './screens/customer_info/customer_notification_screen.dart';
import './screens/customer_info/customer_orders_screen.dart';
import './screens/customer_info/customer_user_info_screen.dart';
import './screens/home_screen.dart';
import './screens/messages_create_screen.dart';
import './screens/navigation_bottom_screen.dart';
import './screens/waste_cart_screen.dart';
import 'classes/strings.dart';
import 'customer_info.dart';
import 'provider/Products.dart';
import 'screens/customer_info/customer_detail_info_edit_screen.dart';
import 'screens/customer_info/login_screen.dart';
import 'screens/customer_info/profile_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/message_detail_screen.dart';
import 'screens/messages_create_reply_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/order_view_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_screen.dart';
import 'screens/splash_Screen.dart';

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
      ],
      child: MaterialApp(
        title: Strings.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.amber,
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyText1: TextStyle(
                  fontFamily: 'Iransans',
                  color: Color.fromRGBO(20, 51, 51, 1),
                ),
                bodyText2: TextStyle(
                  fontFamily: 'Iransans',
                  color: Color.fromRGBO(20, 51, 51, 1),
                ),
                headline1: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Iransans',
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        supportedLocales: const <Locale>[
          Locale('en', ''),
          Locale('ar', ''),
        ],
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
          CashPaymentScreen.routeName: (ctx) => CashPaymentScreen(),
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
        },
      ),
    );
  }
}
