import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_models.dart';

/// Loads and mutates support tickets via the backend REST API.
class SupportTicketRepository {
  SupportTicketRepository(this._client);

  final ApiClient _client;

  static const String _base = 'recycleorigin/v1/tickets';

  Future<Result<PagedTickets>> listTickets({int page = 1, int perPage = 20}) {
    return _client.get<PagedTickets>(
      _base,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
      },
      parser: (dynamic data) {
        final map = data as Map<String, dynamic>;
        final raw = map['items'] as List<dynamic>? ?? <dynamic>[];
        final items = raw
            .map((dynamic e) =>
                SupportTicket.fromJson(e as Map<String, dynamic>))
            .toList();
        return PagedTickets(
          items: items,
          total: (map['total'] as num?)?.toInt() ?? 0,
          page: (map['page'] as num?)?.toInt() ?? page,
          perPage: (map['per_page'] as num?)?.toInt() ?? perPage,
        );
      },
    );
  }

  Future<Result<SupportTicket>> getTicket(String id) {
    return _client.get<SupportTicket>(
      '$_base/$id',
      parser: (dynamic data) =>
          SupportTicket.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Result<PagedMessages>> listMessages(
    String ticketId, {
    int page = 1,
    int perPage = 100,
  }) {
    return _client.get<PagedMessages>(
      '$_base/$ticketId/messages',
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
      },
      parser: (dynamic data) {
        final map = data as Map<String, dynamic>;
        final raw = map['items'] as List<dynamic>? ?? <dynamic>[];
        final items = raw
            .map((dynamic e) => SupportTicketMessage.fromJson(
                  e as Map<String, dynamic>,
                ))
            .toList();
        return PagedMessages(
          items: items,
          total: (map['total'] as num?)?.toInt() ?? 0,
          page: (map['page'] as num?)?.toInt() ?? page,
          perPage: (map['per_page'] as num?)?.toInt() ?? perPage,
        );
      },
    );
  }

  Future<Result<SupportTicket>> createTicket({
    required String subject,
    required String category,
    required String description,
    String? relatedTripId,
  }) {
    final body = <String, dynamic>{
      'subject': subject,
      'category': category,
      'description': description,
    };
    if (relatedTripId != null && relatedTripId.isNotEmpty) {
      body['related_trip_id'] = int.tryParse(relatedTripId);
    }
    return _client.post<SupportTicket>(
      _base,
      data: body,
      parser: (dynamic data) =>
          SupportTicket.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Result<SupportTicketMessage>> postMessage(
    String ticketId,
    String content,
  ) {
    return _client.post<SupportTicketMessage>(
      '$_base/$ticketId/messages',
      data: <String, dynamic>{'content': content},
      parser: (dynamic data) =>
          SupportTicketMessage.fromJson(data as Map<String, dynamic>),
    );
  }
}
