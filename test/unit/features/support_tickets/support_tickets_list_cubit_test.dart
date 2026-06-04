import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_models.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_repository.dart';
import 'package:recycleorigin/features/support_tickets/presentation/cubit/support_tickets_list_cubit.dart';

import '../../../helpers/mock_api_client.dart';

void main() {
  group('SupportTicketsListCubit', () {
    blocTest<SupportTicketsListCubit, SupportTicketsListState>(
      'load emits loading then ready with empty page',
      build: () {
        final mock = MockApiClient();
        mock.setGetResponse(
          'recycleorigin/v1/tickets?page=1&per_page=20',
          Success<Map<String, dynamic>>(<String, dynamic>{
            'items': <dynamic>[],
            'total': 0,
            'page': 1,
            'per_page': 20,
          }),
        );
        return SupportTicketsListCubit(SupportTicketRepository(mock));
      },
      act: (c) => c.load(),
      expect: () => [
        const SupportTicketsListLoading(),
        isA<SupportTicketsListReady>().having(
          (SupportTicketsListReady s) => s.page.total,
          'total',
          0,
        ),
      ],
    );

    blocTest<SupportTicketsListCubit, SupportTicketsListState>(
      'load emits failure when API fails',
      build: () {
        final mock = MockApiClient();
        mock.setGetResponse(
          'recycleorigin/v1/tickets?page=1&per_page=20',
          const Failure<PagedTickets>('offline'),
        );
        return SupportTicketsListCubit(SupportTicketRepository(mock));
      },
      act: (c) => c.load(),
      expect: () => [
        const SupportTicketsListLoading(),
        isA<SupportTicketsListFailed>().having(
          (SupportTicketsListFailed s) => s.message,
          'message',
          'offline',
        ),
      ],
    );
  });
}
