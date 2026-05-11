import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/articles_feature/presentation/bloc/articles_bloc.dart';

Future<void> _flushBlocEvents() => Future<void>.delayed(Duration.zero);

void main() {
  group('ArticlesBloc', () {
    late ArticlesBloc articlesBloc;

    setUp(() {
      articlesBloc = ArticlesBloc();
    });

    group('Initial state', () {
      test('should initialize with empty articles list', () {
        expect(articlesBloc.articleItems, isEmpty);
      });

      test('should initialize with empty waste cart items', () {
        expect(articlesBloc.wasteCartItemsId, isEmpty);
      });

      test('should initialize with default pagination', () {
        expect(articlesBloc.sPage, 1);
        expect(articlesBloc.sPerPage, 10);
      });

      test('should initialize with default category', () {
        expect(articlesBloc.sCategory, isNull);
      });
    });

    group('searchBuilder', () {
      test('should build search endpoint with search key', () async {
        articlesBloc.searchKey = 'test';
        articlesBloc.sPage = 1;
        articlesBloc.sPerPage = 10;
        articlesBloc.searchBuilder();
        await _flushBlocEvents();
        expect(articlesBloc.searchEndPoint, contains('search=test'));
        expect(articlesBloc.searchEndPoint, contains('page=1'));
        expect(articlesBloc.searchEndPoint, contains('per_page=10'));
      });

      test('should build search endpoint without search key', () async {
        articlesBloc.searchKey = '';
        articlesBloc.sPage = 2;
        articlesBloc.sPerPage = 20;
        articlesBloc.searchBuilder();
        await _flushBlocEvents();
        expect(articlesBloc.searchEndPoint, isNot(contains('search=')));
        expect(articlesBloc.searchEndPoint, contains('page=2'));
        expect(articlesBloc.searchEndPoint, contains('per_page=20'));
      });

      test('should build search endpoint with category', () async {
        articlesBloc.sCategory = 5;
        articlesBloc.searchBuilder();
        await _flushBlocEvents();
        expect(articlesBloc.searchEndPoint, contains('cat=5'));
      });
    });

    group('Category management', () {
      test('should set category correctly', () async {
        articlesBloc.sCategory = 5;
        await _flushBlocEvents();
        expect(articlesBloc.sCategory, 5);
      });
    });

    group('Pagination setters', () {
      test('should set page correctly', () async {
        articlesBloc.sPage = 5;
        await _flushBlocEvents();
        expect(articlesBloc.sPage, 5);
      });
    });
  });
}
