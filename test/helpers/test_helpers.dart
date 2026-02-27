import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/features/articles_feature/presentation/providers/articles.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/providers/clearings.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/authentication_provider.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/customer_info_provider.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/providers/messages.dart';
import 'package:recycleorigin/features/store_feature/presentation/providers/Products.dart';
import 'package:recycleorigin/features/store_feature/presentation/providers/orders.dart';
import 'package:recycleorigin/features/waste_feature/presentation/providers/wastes.dart';
import 'mock_api_client.dart';

/// Test helper utilities for creating test widgets and providers
class TestHelpers {
  /// Creates a test widget with all providers
  static Widget createTestWidget({
    required Widget child,
    ApiClient? apiClient,
    Products? products,
    AuthenticationProvider? authProvider,
    CustomerInfoProvider? customerInfoProvider,
    Messages? messages,
    Wastes? wastes,
    Articles? articles,
    Orders? orders,
    Clearings? clearings,
  }) {
    // Use MockApiClient by default for testing
    final testApiClient = apiClient ?? MockApiClient();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Products>(
          create: (_) => products ?? Products(testApiClient),
        ),
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) =>
              authProvider ?? AuthenticationProvider(testApiClient),
        ),
        ChangeNotifierProvider<CustomerInfoProvider>(
          create: (_) => customerInfoProvider ?? CustomerInfoProvider(testApiClient),
        ),
        ChangeNotifierProvider<Messages>(
          create: (_) => messages ?? Messages(),
        ),
        ChangeNotifierProvider<Wastes>(
          create: (_) => wastes ?? Wastes(),
        ),
        ChangeNotifierProvider<Articles>(
          create: (_) => articles ?? Articles(),
        ),
        ChangeNotifierProvider<Orders>(
          create: (_) => orders ?? Orders(),
        ),
        ChangeNotifierProvider<Clearings>(
          create: (_) => clearings ?? Clearings(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  /// Creates a simple test widget with MaterialApp
  static Widget createSimpleTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Pumps widget and waits for async operations
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle();
  }

  /// Waits for a specific duration
  static Future<void> waitFor(Duration duration) async {
    await Future.delayed(duration);
  }
}

/// Test constants
class TestConstants {
  static const String testToken = 'test_token_12345';
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testPhone = '+1234567890';
  static const String testUrl = 'https://example.com';
  static const int testProductId = 1;
  static const int testArticleId = 1;
  static const String testApiBaseUrl = 'https://test-api.example.com';
}
