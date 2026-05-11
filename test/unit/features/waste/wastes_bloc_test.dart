import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_event.dart';
import 'package:recycleorigin/features/waste_feature/presentation/bloc/wastes_state.dart';

import '../../../fixtures/waste_fixtures.dart';

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  group('WastesBloc', () {
    late WastesBloc bloc;

    setUp(() {
      bloc = WastesBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    group('searchBuilder', () {
      test('builds query with pagination and sort', () async {
        bloc.add(const WastesSearchParamsChanged(searchKey: 'metal'));
        await _tick();
        bloc.sPage = 2;
        bloc.sPerPage = 15;
        bloc.searchBuilder();
        await _tick();
        expect(bloc.searchEndPoint, contains('search=metal'));
        expect(bloc.searchEndPoint, contains('page=2'));
        expect(bloc.searchEndPoint, contains('per_page=15'));
        expect(bloc.searchEndPoint, contains('order=desc'));
        expect(bloc.searchEndPoint, contains('orderby=date'));
      });

      test('includes category when set', () async {
        bloc.sCategory = 7;
        bloc.searchBuilder();
        await _tick();
        expect(bloc.searchEndPoint, contains('category=7'));
      });
    });

    blocTest<WastesBloc, WastesState>(
      'markRequestsListDirty sets flag',
      build: WastesBloc.new,
      act: (b) => b.markRequestsListDirty(),
      expect: () => [
        isA<WastesState>().having((s) => s.requestsListDirty, 'dirty', true),
      ],
    );

    group('cart', () {
      test('addWasteCart appends item and id', () async {
        final w = sampleWaste(id: 10, name: 'Glass');
        await bloc.addWasteCart(w, 3);
        await _tick();
        expect(bloc.wasteCartItems, hasLength(1));
        expect(bloc.wasteCartItems.first.weight, 3);
        expect(bloc.wasteCartItemsId, contains(10));
      });

      test('updateWasteCart changes weight', () async {
        final w = sampleWaste(id: 20);
        await bloc.addWasteCart(w, 1);
        await _tick();
        await bloc.updateWasteCart(bloc.wasteCartItems.first, 9);
        await _tick();
        expect(bloc.wasteCartItems.first.weight, 9);
      });

      test('removeWasteCart drops item', () async {
        final w = sampleWaste(id: 30);
        await bloc.addWasteCart(w, 1);
        await _tick();
        await bloc.removeWasteCart(30);
        await _tick();
        expect(bloc.wasteCartItems, isEmpty);
        expect(bloc.wasteCartItemsId, isEmpty);
      });
    });

    blocTest<WastesBloc, WastesState>(
      'selectedHours and selectedDay update state',
      build: WastesBloc.new,
      act: (b) {
        b.selectedHours = '14-16';
        b.selectedDay = DateTime(2026, 6, 15);
      },
      expect: () => [
        isA<WastesState>().having((s) => s.selectedHours, 'hours', '14-16'),
        isA<WastesState>().having((s) => s.selectedDay.day, 'day', 15),
      ],
    );
  });
}
