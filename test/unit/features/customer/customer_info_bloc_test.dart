import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/core/models/status.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/personal_data.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/bloc/customer_info_event.dart';

import '../../../fixtures/customer_api_fixtures.dart';
import '../../../helpers/mock_api_client.dart';

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  group('CustomerInfoBloc', () {
    late MockApiClient mockApi;
    late CustomerInfoBloc bloc;

    setUp(() {
      mockApi = MockApiClient();
      bloc = CustomerInfoBloc(mockApi);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('searchBuilder adds pagination, order, and search', () async {
      bloc.add(const CustomerSearchParamsChanged(searchKey: 'refund'));
      await _tick();
      bloc.searchBuilder();
      await _tick();
      expect(bloc.searchEndPoint, contains('search=refund'));
      expect(bloc.searchEndPoint, contains('page=1'));
      expect(bloc.searchEndPoint, contains('per_page=10'));
      expect(bloc.searchEndPoint, contains('order=desc'));
      expect(bloc.searchEndPoint, contains('orderby=date'));
    });

    test('sendCustomer refreshes profile from API after POST', () async {
      const customerPath = 'recycleorigin/v1/customer';
      mockApi.setPostResponse(
        customerPath,
        Success<Map<String, dynamic>>(<String, dynamic>{}),
      );
      mockApi.setGetResponse(
        customerPath,
        Success<Map<String, dynamic>>(
          sampleCustomerJson(firstName: 'Updated', lastName: 'User'),
        ),
      );

      final customer = Customer(
        customer_type: Status(term_id: 2, name: 'individual', slug: 'individual'),
        personalData: PersonalData(
          first_name: 'Updated',
          last_name: 'User',
          email: 'ada@example.com',
          mobile: '+905551234567',
        ),
      );

      await bloc.sendCustomer(customer);
      await _tick();

      expect(bloc.state.customer.personalData.first_name, 'Updated');
      expect(bloc.state.customer.personalData.last_name, 'User');
    });

    test('getCustomer maps API payload into state', () async {
      mockApi.setGetResponse(
        'recycleorigin/v1/customer',
        Success<Map<String, dynamic>>(sampleCustomerJson()),
      );

      await bloc.getCustomer();
      await _tick();

      expect(bloc.state.customer.id, 42);
      expect(bloc.state.customer.personalData.first_name, 'Ada');
      expect(bloc.state.customer.personalData.email, 'ada@example.com');
    });

    test('searchTransactionItems applies empty result', () async {
      mockApi.setGetResponse(
        'recycleorigin/v1/transactions?page=1&per_page=10&order=desc&orderby=date',
        Success<Map<String, dynamic>>(<String, dynamic>{
          'data': <dynamic>[],
          'details': <String, dynamic>{
            'total': 0,
            'max_pages': 1,
          },
        }),
      );

      bloc.searchBuilder();
      await _tick();
      await bloc.searchTransactionItems();
      await _tick();

      expect(bloc.state.transactionItems, isEmpty);
      expect(bloc.state.searchDetails.total, 0);
    });
  });
}
