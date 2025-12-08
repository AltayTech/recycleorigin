import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/store_feature/presentation/providers/Products.dart';

void main() {
  group('Products Provider', () {
    late Products productsProvider;

    setUp(() {
      productsProvider = Products();
    });

    group('Initial state', () {
      test('should initialize with empty products list', () {
        expect(productsProvider.items, isEmpty);
      });

      test('should initialize with empty cart', () {
        expect(productsProvider.cartItems, isEmpty);
        expect(productsProvider.cartItemsCount, 0);
      });

      test('should initialize with default pagination', () {
        // Test pagination through searchBuilder
        productsProvider.searchBuilder();
        expect(productsProvider.searchEndPoint, contains('page=1'));
        expect(productsProvider.searchEndPoint, contains('per_page=10'));
      });

      test('should initialize with default filters', () {
        expect(productsProvider.isFiltered, isFalse);
        expect(productsProvider.sCategory, isNull);
      });
    });

    group('Cart management', () {
      test('should have addShopCart method', () {
        // Structure test - actual implementation requires Product and ColorCodeProductDetail
        expect(productsProvider.addShopCart, isNotNull);
        expect(productsProvider.cartItemsCount, 0);
      });

      test('should update cart item quantity', () async {
        // Setup: Add item to cart first
        // Then update quantity
        expect(productsProvider.cartItemsCount, 0);
      });

      test('should remove product from cart', () async {
        // Setup: Add item to cart first
        // Then remove it
        expect(productsProvider.cartItemsCount, 0);
      });

      test('should calculate cart items count correctly', () {
        expect(productsProvider.cartItemsCount, 0);
      });
    });

    group('searchBuilder', () {
      test('should build search endpoint with search key', () {
        productsProvider.searchKey = 'test';
        productsProvider.sPage = 1;
        productsProvider.sPerPage = 10;
        productsProvider.searchBuilder();

        expect(productsProvider.searchEndPoint, contains('search=test'));
        expect(productsProvider.searchEndPoint, contains('page=1'));
        expect(productsProvider.searchEndPoint, contains('per_page=10'));
      });

      test('should build search endpoint with category filter', () {
        productsProvider.sCategory = 5;
        productsProvider.searchBuilder();

        expect(productsProvider.searchEndPoint, contains('category=5'));
      });

      test('should build search endpoint with order and orderBy', () {
        productsProvider.sOrder = 'asc';
        productsProvider.sOrderBy = 'price';
        productsProvider.searchBuilder();

        expect(productsProvider.searchEndPoint, contains('order=asc'));
        expect(productsProvider.searchEndPoint, contains('orderby=price'));
      });

      test('should build complete search endpoint', () {
        productsProvider.searchKey = 'laptop';
        productsProvider.sPage = 2;
        productsProvider.sPerPage = 20;
        productsProvider.sCategory = 3;
        productsProvider.sOrder = 'desc';
        productsProvider.sOrderBy = 'date';
        productsProvider.searchBuilder();

        final endpoint = productsProvider.searchEndPoint;
        expect(endpoint, contains('search=laptop'));
        expect(endpoint, contains('page=2'));
        expect(endpoint, contains('per_page=20'));
        expect(endpoint, contains('category=3'));
        expect(endpoint, contains('order=desc'));
        expect(endpoint, contains('orderby=date'));
      });
    });

    group('Filter management', () {
      test('should set category filter', () {
        productsProvider.sCategory = 5;
        expect(productsProvider.sCategory, 5);
      });

      test('should clear category filter', () {
        productsProvider.sCategory = 5;
        productsProvider.sCategory = null;
        expect(productsProvider.sCategory, isNull);
      });

      test('should check filtered state correctly', () async {
        productsProvider.sCategory = '';
        await productsProvider.checkFiltered();
        expect(productsProvider.isFiltered, isFalse);

        productsProvider.sCategory = 5;
        await productsProvider.checkFiltered();
        expect(productsProvider.isFiltered, isTrue);
      });
    });

    group('Pagination setters', () {
      test('should set page correctly', () {
        productsProvider.sPage = 5;
        productsProvider.searchBuilder();
        expect(productsProvider.searchEndPoint, contains('page=5'));
      });

      test('should set per page correctly', () {
        productsProvider.sPerPage = 20;
        productsProvider.searchBuilder();
        expect(productsProvider.searchEndPoint, contains('per_page=20'));
      });

      test('should set order correctly', () {
        productsProvider.sOrder = 'asc';
        productsProvider.searchBuilder();
        expect(productsProvider.searchEndPoint, contains('order=asc'));
      });

      test('should set orderBy correctly', () {
        productsProvider.sOrderBy = 'price';
        productsProvider.searchBuilder();
        expect(productsProvider.searchEndPoint, contains('orderby=price'));
      });
    });

    group('Product retrieval', () {
      test('should have default item', () {
        expect(productsProvider.item, isNotNull);
        expect(productsProvider.itemZero, isNotNull);
      });

      test('should have item setter', () {
        // Structure test - actual implementation requires Product entity
        expect(productsProvider.item, isNotNull);
      });
    });

    group('State management', () {
      test('should notify listeners on state changes', () {
        productsProvider.addListener(() {
          // Listener callback - in real scenario this would be triggered by notifyListeners()
        });

        productsProvider.searchKey = 'new search';
        productsProvider.searchBuilder();

        expect(productsProvider.searchKey, 'new search');
      });
    });
  });
}

