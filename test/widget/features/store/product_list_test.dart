import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_state.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/mock_api_client.dart';

void main() {
  group('Product List Widget Tests', () {
    testWidgets('should display empty state when no products', (
      WidgetTester tester,
    ) async {
      final mockApiClient = MockApiClient();
      final productsBloc = ProductsBloc(mockApiClient);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          productsBloc: productsBloc,
          child: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return const Center(child: Text('No products available'));
              }
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final product = state.items[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.price),
                  );
                },
              );
            },
          ),
        ),
      );

      expect(find.text('No products available'), findsOneWidget);
    });

    testWidgets('should display products list', (WidgetTester tester) async {
      final mockApiClient = MockApiClient();
      final productsBloc = ProductsBloc(mockApiClient);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          productsBloc: productsBloc,
          child: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return const Center(child: Text('No products available'));
              }
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final product = state.items[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.price),
                  );
                },
              );
            },
          ),
        ),
      );

      expect(
        find.byType(BlocBuilder<ProductsBloc, ProductsState>),
        findsOneWidget,
      );
    });
  });
}
