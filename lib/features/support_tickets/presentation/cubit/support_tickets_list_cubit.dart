import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_models.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_repository.dart';

sealed class SupportTicketsListState {
  const SupportTicketsListState();
}

final class SupportTicketsListInitial extends SupportTicketsListState {
  const SupportTicketsListInitial();
}

final class SupportTicketsListLoading extends SupportTicketsListState {
  const SupportTicketsListLoading();
}

final class SupportTicketsListReady extends SupportTicketsListState {
  const SupportTicketsListReady(this.page);
  final PagedTickets page;
}

final class SupportTicketsListFailed extends SupportTicketsListState {
  const SupportTicketsListFailed(this.message);
  final String message;
}

/// Loads the signed-in user’s support tickets.
class SupportTicketsListCubit extends Cubit<SupportTicketsListState> {
  SupportTicketsListCubit(this._repo) : super(const SupportTicketsListInitial());

  final SupportTicketRepository _repo;

  Future<void> load({int page = 1}) async {
    emit(const SupportTicketsListLoading());
    final Result<PagedTickets> r = await _repo.listTickets(page: page);
    switch (r) {
      case Success(:final value):
        emit(SupportTicketsListReady(value));
      case Failure(:final message):
        emit(SupportTicketsListFailed(message));
    }
  }
}
