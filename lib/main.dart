import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/Charities/presentation/pages/charity_detail_screen.dart';
import 'package:recycleorigin/features/Charities/presentation/pages/charity_screen.dart';
import 'package:recycleorigin/features/Charities/presentation/pages/donation_screen.dart';
import 'package:recycleorigin/features/Charities/presentation/providers/charities.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/pages/clear_screen.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/providers/clearings.dart';
import 'package:recycleorigin/features/store_feature/presentation/providers/orders.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/orders_screen.dart';
import 'package:recycleorigin/features/wallet_feature/presentation/pages/wallet_screen.dart';
import 'package:recycleorigin/features/waste_feature/collect_detail_screen.dart';
import 'package:recycleorigin/features/waste_feature/presentation/wastes_screen_animated_list.dart';

import 'core/constants/strings.dart';
import 'core/screens/navigation_bottom_screen.dart';
import 'core/screens/splash_Screen.dart';
import 'features/about_feature/presentation/pages/about_us_screen.dart';
import 'features/articles_feature/presentation/pages/article_detail_screen.dart';
import 'features/articles_feature/presentation/pages/article_screen.dart';
import 'features/articles_feature/presentation/providers/articles.dart';
import 'features/collect_feature/presentation/pages/waste_cart_screen.dart';
import 'features/contac_us_feature/presentation/pages/contact_with_us_screen.dart';
import 'features/customer_feature/presentation/providers/authentication_provider.dart';
import 'features/customer_feature/presentation/providers/customer_info_provider.dart';
import 'features/customer_feature/presentation/screens/customer_detail_info_edit_screen.dart';
import 'features/customer_feature/presentation/screens/customer_notification_screen.dart';
import 'features/customer_feature/presentation/screens/customer_orders_screen.dart';
import 'features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'features/customer_feature/presentation/screens/login_screen.dart';
import 'features/customer_feature/presentation/screens/profile_screen.dart';
import 'features/guid_feature/presentation/pages/guide_screen.dart';
import 'features/home_feature/presentation/home_screen.dart';
import 'features/meassage_feature/presentation/pages/message_detail_screen.dart';
import 'features/meassage_feature/presentation/pages/messages_create_reply_screen.dart';
import 'features/meassage_feature/presentation/pages/messages_create_screen.dart';
import 'features/meassage_feature/presentation/pages/messages_screen.dart';
import 'features/meassage_feature/presentation/providers/messages.dart';
import 'features/store_feature/presentation/providers/Products.dart';
import 'features/store_feature/presentation/screens/cart_screen.dart';
import 'features/store_feature/presentation/screens/order_products_send_screen.dart';
import 'features/store_feature/presentation/screens/order_view_screen.dart';
import 'features/store_feature/presentation/screens/product_detail_screen.dart';
import 'features/store_feature/presentation/screens/product_screen.dart';
import 'features/waste_feature/collect_list_screen.dart';
import 'features/waste_feature/presentation/address_screen.dart';
import 'features/waste_feature/presentation/pages/map_screen.dart';
import 'features/waste_feature/presentation/providers/wastes.dart';
import 'features/waste_feature/presentation/waste_request_date_screen.dart';
import 'features/waste_feature/presentation/waste_request_send_screen.dart';
import 'features/waste_feature/presentation/wastes_screen.dart';

/// The main application widget.
///
/// This widget is the root of the application. It uses the [MultiProvider]
/// widget to provide the [Products], [AuthenticationProvider], [CustomerInfoProvider],
/// [Messages], [Wastes], [Articles], [Charities], [Orders], and [Clearings]
/// providers to the application.
///
/// The application's theme is defined in the [MaterialApp] widget. The
/// theme is based on the [Colors.green] color and uses the [Iransans] font.
///
/// The application's routes are defined in the [MaterialApp] widget. The
/// routes are used to navigate between the different screens of the application.
///
/// The application's home screen is [SplashScreens].
///
/// The application's localizations are defined in the [AppLocalizations]
/// class. The localizations are used to translate the application's text
/// into different languages.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

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
          create: (context) => AuthenticationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerInfoProvider(),
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
        // localizationsDelegates: AppLocalizations.localizationsDelegates,
        // supportedLocales: AppLocalizations.supportedLocales,
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
