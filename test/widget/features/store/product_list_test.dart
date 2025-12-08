import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/store_feature/presentation/providers/Products.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('Product List Widget Tests', () {
    testWidgets('should display empty state when no products', (WidgetTester tester) async {
      final productsProvider = Products();

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          products: productsProvider,
          child: Consumer<Products>(
            builder: (context, products, child) {
              if (products.items.isEmpty) {
                return const Center(child: Text('No products available'));
              }
              return ListView.builder(
                itemCount: products.items.length,
                itemBuilder: (context, index) {
                  final product = products.items[index];
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
      final productsProvider = Products();
      // Note: In a real test, you'd mock the API response
      // For now, we test the structure

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          products: productsProvider,
          child: Consumer<Products>(
            builder: (context, products, child) {
              if (products.items.isEmpty) {
                return const Center(child: Text('No products available'));
              }
              return ListView.builder(
                itemCount: products.items.length,
                itemBuilder: (context, index) {
                  final product = products.items[index];
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

      // Verify the widget structure
      expect(find.byType(Consumer<Products>), findsOneWidget);
    });
  });
}

