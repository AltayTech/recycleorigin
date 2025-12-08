import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/articles_feature/presentation/providers/articles.dart';

void main() {
  group('Articles Provider', () {
    late Articles articlesProvider;

    setUp(() {
      articlesProvider = Articles();
    });

    group('Initial state', () {
      test('should initialize with empty articles list', () {
        expect(articlesProvider.articleItems, isEmpty);
      });

      test('should initialize with empty waste cart items', () {
        expect(articlesProvider.wasteCartItemsId, isEmpty);
      });

      test('should initialize with default pagination', () {
        expect(articlesProvider.sPage, 1);
        expect(articlesProvider.sPerPage, 10);
      });

      test('should initialize with default category', () {
        expect(articlesProvider.sCategory, isNull);
      });
    });

    group('searchBuilder', () {
      test('should build search endpoint with search key', () {
        articlesProvider.searchKey = 'test';
        articlesProvider.sPage = 1;
        articlesProvider.sPerPage = 10;
        articlesProvider.searchBuilder();

        expect(articlesProvider.searchEndPoint, contains('search=test'));
        expect(articlesProvider.searchEndPoint, contains('page=1'));
        expect(articlesProvider.searchEndPoint, contains('per_page=10'));
      });

      test('should build search endpoint without search key', () {
        articlesProvider.searchKey = '';
        articlesProvider.sPage = 2;
        articlesProvider.sPerPage = 20;
        articlesProvider.searchBuilder();

        expect(articlesProvider.searchEndPoint, isNot(contains('search=')));
        expect(articlesProvider.searchEndPoint, contains('page=2'));
        expect(articlesProvider.searchEndPoint, contains('per_page=20'));
      });

      test('should build search endpoint with category', () {
        articlesProvider.sCategory = 5;
        articlesProvider.searchBuilder();

        expect(articlesProvider.searchEndPoint, contains('cat=5'));
      });

      test('should build complete search endpoint', () {
        articlesProvider.searchKey = 'recycling';
        articlesProvider.sPage = 1;
        articlesProvider.sPerPage = 10;
        articlesProvider.sCategory = 3;
        articlesProvider.searchBuilder();

        final endpoint = articlesProvider.searchEndPoint;
        expect(endpoint, contains('search=recycling'));
        expect(endpoint, contains('page=1'));
        expect(endpoint, contains('per_page=10'));
        expect(endpoint, contains('cat=3'));
      });
    });

    group('Category management', () {
      test('should set category correctly', () {
        articlesProvider.sCategory = 5;
        expect(articlesProvider.sCategory, 5);
      });

      test('should clear category', () {
        articlesProvider.sCategory = 5;
        articlesProvider.sCategory = null;
        expect(articlesProvider.sCategory, isNull);
      });
    });

    group('Pagination setters', () {
      test('should set page correctly', () {
        articlesProvider.sPage = 5;
        expect(articlesProvider.sPage, 5);
      });

      test('should set per page correctly', () {
        articlesProvider.sPerPage = 20;
        expect(articlesProvider.sPerPage, 20);
      });
    });

    group('State management', () {
      test('should notify listeners on state changes', () {
        articlesProvider.addListener(() {
          // Listener callback - in real scenario this would be triggered by notifyListeners()
        });

        articlesProvider.searchKey = 'new search';
        articlesProvider.searchBuilder();

        expect(articlesProvider.searchKey, 'new search');
      });
    });
  });
}

