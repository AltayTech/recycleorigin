import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/orders_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/orders_event.dart';
import '../../../helpers/mock_api_client.dart';

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  group('OrdersBloc', () {
    late OrdersBloc ordersBloc;

    setUp(() {
      ordersBloc = OrdersBloc(MockApiClient());
    });

    tearDown(() async {
      await ordersBloc.close();
    });

    test('initial pagination and sort defaults', () {
      expect(ordersBloc.sPage, 1);
      expect(ordersBloc.sPerPage, 10);
      expect(ordersBloc.sOrder, 'desc');
      expect(ordersBloc.sOrderBy, 'date');
    });

    test('searchBuilder with search key', () async {
      ordersBloc.sPage = 1;
      ordersBloc.sPerPage = 10;
      ordersBloc.add(
        const OrdersSearchParamsChanged(searchKey: 'order-42'),
      );
      await _tick();
      ordersBloc.searchBuilder();
      await _tick();
      expect(ordersBloc.searchEndPoint, contains('search=order-42'));
      expect(ordersBloc.searchEndPoint, contains('page=1'));
      expect(ordersBloc.searchEndPoint, contains('per_page=10'));
      expect(ordersBloc.searchEndPoint, contains('order=desc'));
      expect(ordersBloc.searchEndPoint, contains('orderby=date'));
    });

    test('searchBuilder without search key uses pagination only', () async {
      ordersBloc.add(const OrdersSearchParamsChanged(searchKey: ''));
      await _tick();
      ordersBloc.sPage = 3;
      ordersBloc.searchBuilder();
      await _tick();
      expect(ordersBloc.searchEndPoint, contains('page=3'));
      expect(ordersBloc.searchEndPoint, contains('per_page=10'));
      expect(ordersBloc.searchEndPoint, contains('order=desc'));
      expect(ordersBloc.searchEndPoint, contains('orderby=date'));
    });
  });
}
