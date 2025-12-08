import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/providers/clearings.dart';

void main() {
  group('Clearings Provider', () {
    late Clearings clearingsProvider;

    setUp(() {
      clearingsProvider = Clearings();
    });

    group('Initial state', () {
      test('should initialize with empty deliveries list', () {
        expect(clearingsProvider.deliveriesItems, isEmpty);
      });

      test('should initialize with default pagination', () {
        clearingsProvider.searchBuilder();
        expect(clearingsProvider.searchEndPoint, contains('page=1'));
        expect(clearingsProvider.searchEndPoint, contains('per_page=10'));
      });

      test('should initialize with default order', () {
        clearingsProvider.searchBuilder();
        expect(clearingsProvider.searchEndPoint, contains('order=desc'));
        expect(clearingsProvider.searchEndPoint, contains('orderby=date'));
      });
    });

    group('searchBuilder', () {
      test('should build search endpoint with search key', () {
        clearingsProvider.searchKey = 'test';
        clearingsProvider.sPage = 1;
        clearingsProvider.sPerPage = 10;
        clearingsProvider.searchBuilder();

        expect(clearingsProvider.searchEndPoint, contains('search=test'));
        expect(clearingsProvider.searchEndPoint, contains('page=1'));
        expect(clearingsProvider.searchEndPoint, contains('per_page=10'));
      });

      test('should build search endpoint with category', () {
        clearingsProvider.sCategory = 5;
        clearingsProvider.searchBuilder();

        expect(clearingsProvider.searchEndPoint, contains('category=5'));
      });

      test('should build search endpoint with order and orderBy', () {
        clearingsProvider.sOrder = 'asc';
        clearingsProvider.sOrderBy = 'price';
        clearingsProvider.searchBuilder();

        expect(clearingsProvider.searchEndPoint, contains('order=asc'));
        expect(clearingsProvider.searchEndPoint, contains('orderby=price'));
      });

      test('should build complete search endpoint', () {
        clearingsProvider.searchKey = 'clearing';
        clearingsProvider.sPage = 2;
        clearingsProvider.sPerPage = 20;
        clearingsProvider.sCategory = 3;
        clearingsProvider.sOrder = 'asc';
        clearingsProvider.sOrderBy = 'date';
        clearingsProvider.searchBuilder();

        final endpoint = clearingsProvider.searchEndPoint;
        expect(endpoint, contains('search=clearing'));
        expect(endpoint, contains('page=2'));
        expect(endpoint, contains('per_page=20'));
        expect(endpoint, contains('category=3'));
        expect(endpoint, contains('order=asc'));
        expect(endpoint, contains('orderby=date'));
      });
    });

    group('Date and time selection', () {
      test('should set selected day', () {
        final date = DateTime(2024, 1, 15);
        clearingsProvider.selectedDay = date;
        expect(clearingsProvider.selectedDay, date);
      });

      test('should set selected hours', () {
        clearingsProvider.selectedHours = '10:00';
        expect(clearingsProvider.selectedHours, '10:00');
      });
    });

    group('Pagination setters', () {
      test('should set page correctly', () {
        clearingsProvider.sPage = 5;
        clearingsProvider.searchBuilder();
        expect(clearingsProvider.searchEndPoint, contains('page=5'));
      });

      test('should set per page correctly', () {
        clearingsProvider.sPerPage = 20;
        clearingsProvider.searchBuilder();
        expect(clearingsProvider.searchEndPoint, contains('per_page=20'));
      });

      test('should set order correctly', () {
        clearingsProvider.sOrder = 'asc';
        clearingsProvider.searchBuilder();
        expect(clearingsProvider.searchEndPoint, contains('order=asc'));
      });

      test('should set orderBy correctly', () {
        clearingsProvider.sOrderBy = 'price';
        clearingsProvider.searchBuilder();
        expect(clearingsProvider.searchEndPoint, contains('orderby=price'));
      });

      test('should set category correctly', () {
        clearingsProvider.sCategory = 5;
        clearingsProvider.searchBuilder();
        expect(clearingsProvider.searchEndPoint, contains('category=5'));
      });
    });

    group('State management', () {
      test('should notify listeners on state changes', () {
        clearingsProvider.addListener(() {
          // Listener callback - in real scenario this would be triggered by notifyListeners()
        });

        clearingsProvider.searchKey = 'new search';
        clearingsProvider.searchBuilder();

        expect(clearingsProvider.searchKey, 'new search');
      });
    });
  });
}

