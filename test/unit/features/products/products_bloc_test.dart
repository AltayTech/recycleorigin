import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_bloc.dart';
import '../../../helpers/mock_api_client.dart';

Future<void> _flushBlocEvents() => Future<void>.delayed(Duration.zero);

void main() {
  group('ProductsBloc', () {
    late ProductsBloc productsBloc;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      productsBloc = ProductsBloc(mockApiClient);
    });

    group('Initial state', () {
      test('should initialize with empty products list', () {
        expect(productsBloc.items, isEmpty);
      });

      test('should initialize with empty cart', () {
        expect(productsBloc.cartItems, isEmpty);
        expect(productsBloc.cartItemsCount, 0);
      });

      test('should initialize with default pagination', () async {
        productsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(productsBloc.searchEndPoint, contains('page=1'));
        expect(productsBloc.searchEndPoint, contains('per_page=10'));
      });

      test('should initialize with default filters', () {
        expect(productsBloc.isFiltered, isFalse);
        expect(productsBloc.sCategory, isNull);
      });
    });

    group('Cart management', () {
      test('should have addShopCart method', () {
        expect(productsBloc.addShopCart, isNotNull);
        expect(productsBloc.cartItemsCount, 0);
      });
    });

    group('searchBuilder', () {
      test('should build search endpoint with search key', () async {
        productsBloc.searchKey = 'test';
        productsBloc.sPage = 1;
        productsBloc.sPerPage = 10;
        productsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(productsBloc.searchEndPoint, contains('search=test'));
        expect(productsBloc.searchEndPoint, contains('page=1'));
        expect(productsBloc.searchEndPoint, contains('per_page=10'));
      });

      test('should build search endpoint with category filter', () async {
        productsBloc.sCategory = 5;
        productsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(productsBloc.searchEndPoint, contains('category=5'));
      });

      test('should build search endpoint with order and orderBy', () async {
        productsBloc.sOrder = 'asc';
        productsBloc.sOrderBy = 'price';
        productsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(productsBloc.searchEndPoint, contains('order=asc'));
        expect(productsBloc.searchEndPoint, contains('orderby=price'));
      });

      test('should build complete search endpoint', () async {
        productsBloc.searchKey = 'laptop';
        productsBloc.sPage = 2;
        productsBloc.sPerPage = 20;
        productsBloc.sCategory = 3;
        productsBloc.sOrder = 'desc';
        productsBloc.sOrderBy = 'date';
        productsBloc.searchBuilder();
        await _flushBlocEvents();
        final endpoint = productsBloc.searchEndPoint;
        expect(endpoint, contains('search=laptop'));
        expect(endpoint, contains('page=2'));
        expect(endpoint, contains('per_page=20'));
        expect(endpoint, contains('category=3'));
        expect(endpoint, contains('order=desc'));
        expect(endpoint, contains('orderby=date'));
      });
    });

    group('Filter management', () {
      test('should set category filter', () async {
        productsBloc.sCategory = 5;
        await _flushBlocEvents();
        expect(productsBloc.sCategory, 5);
      });

      test('should clear category filter', () async {
        productsBloc.sCategory = 5;
        await _flushBlocEvents();
        productsBloc.sCategory = null;
        await _flushBlocEvents();
        expect(productsBloc.sCategory, isNull);
      });

      test('should check filtered state correctly', () async {
        productsBloc.sCategory = '';
        await _flushBlocEvents();
        await productsBloc.checkFiltered();
        await _flushBlocEvents();
        expect(productsBloc.isFiltered, isFalse);

        productsBloc.sCategory = 5;
        await _flushBlocEvents();
        await productsBloc.checkFiltered();
        await _flushBlocEvents();
        expect(productsBloc.isFiltered, isTrue);
      });
    });

    group('Pagination setters', () {
      test('should set page correctly', () async {
        productsBloc.sPage = 5;
        productsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(productsBloc.searchEndPoint, contains('page=5'));
      });

      test('should set per page correctly', () async {
        productsBloc.sPerPage = 20;
        productsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(productsBloc.searchEndPoint, contains('per_page=20'));
      });
    });

    group('Product retrieval', () {
      test('should have default item', () {
        expect(productsBloc.item, isNotNull);
        expect(ProductsBloc.itemZero, isNotNull);
      });
    });
  });
}
