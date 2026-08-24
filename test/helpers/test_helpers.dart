import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/features/articles_feature/presentation/bloc/articles_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/orders_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_bloc.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_bloc.dart';
import 'mock_api_client.dart';

/// Test helper utilities for creating test widgets and providers
class TestHelpers {
  /// Creates a test widget with all providers
  static Widget createTestWidget({
    required Widget child,
    ApiClient? apiClient,
    ProductsBloc? productsBloc,
    AuthBloc? authBloc,
    CustomerInfoBloc? customerInfoBloc,
    MessagesBloc? messagesBloc,
    WastesBloc? wastesBloc,
    ArticlesBloc? articlesBloc,
    OrdersBloc? ordersBloc,
    ClearingsBloc? clearingsBloc,
  }) {
    // Use MockApiClient by default for testing
    final testApiClient = apiClient ?? MockApiClient();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsBloc>(
          create: (_) => productsBloc ?? ProductsBloc(testApiClient),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => authBloc ?? AuthBloc(testApiClient),
        ),
        BlocProvider<CustomerInfoBloc>(
          create: (_) => customerInfoBloc ?? CustomerInfoBloc(testApiClient),
        ),
        BlocProvider<MessagesBloc>(
          create: (_) => messagesBloc ?? MessagesBloc(testApiClient),
        ),
        BlocProvider<WastesBloc>(
          create: (_) => wastesBloc ?? WastesBloc(),
        ),
        BlocProvider<ArticlesBloc>(
          create: (_) => articlesBloc ?? ArticlesBloc(),
        ),
        BlocProvider<OrdersBloc>(
          create: (_) => ordersBloc ?? OrdersBloc(testApiClient),
        ),
        BlocProvider<ClearingsBloc>(
          create: (_) => clearingsBloc ?? ClearingsBloc(testApiClient),
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
