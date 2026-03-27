import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/clearing_feature/presentation/bloc/clearings_bloc.dart';

Future<void> _flushBlocEvents() => Future<void>.delayed(Duration.zero);

void main() {
  group('ClearingsBloc', () {
    late ClearingsBloc clearingsBloc;

    setUp(() {
      clearingsBloc = ClearingsBloc();
    });

    group('Initial state', () {
      test('should initialize with empty deliveries list', () {
        expect(clearingsBloc.deliveriesItems, isEmpty);
      });

      test('should initialize with default pagination', () async {
        clearingsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(clearingsBloc.searchEndPoint, contains('page=1'));
        expect(clearingsBloc.searchEndPoint, contains('per_page=10'));
      });

      test('should initialize with default order', () async {
        clearingsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(clearingsBloc.searchEndPoint, contains('order=desc'));
        expect(clearingsBloc.searchEndPoint, contains('orderby=date'));
      });
    });

    group('searchBuilder', () {
      test('should build search endpoint with search key', () async {
        clearingsBloc.searchKey = 'test';
        clearingsBloc.sPage = 1;
        clearingsBloc.sPerPage = 10;
        clearingsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(clearingsBloc.searchEndPoint, contains('search=test'));
      });

      test('should build search endpoint with category', () async {
        clearingsBloc.sCategory = 5;
        clearingsBloc.searchBuilder();
        await _flushBlocEvents();
        expect(clearingsBloc.searchEndPoint, contains('category=5'));
      });
    });

    group('Date and time selection', () {
      test('should set selected day', () async {
        final date = DateTime(2024, 1, 15);
        clearingsBloc.selectedDay = date;
        await _flushBlocEvents();
        expect(clearingsBloc.selectedDay, date);
      });

      test('should set selected hours', () async {
        clearingsBloc.selectedHours = '10:00';
        await _flushBlocEvents();
        expect(clearingsBloc.selectedHours, '10:00');
      });
    });
  });
}
