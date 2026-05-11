/// API models for support tickets (`/pasmands/v1/tickets`).
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdBy,
    required this.createdByRole,
    this.assignedTo,
    this.relatedTripId,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  final String id;
  final String ticketNumber;
  final String subject;
  final String category;
  final String status;
  final String priority;
  final String createdBy;
  final String createdByRole;
  final String? assignedTo;
  final String? relatedTripId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String,
      subject: json['subject'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      createdBy: json['created_by'] as String,
      createdByRole: json['created_by_role'] as String,
      assignedTo: json['assigned_to'] as String?,
      relatedTripId: json['related_trip_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
    );
  }
}

class SupportTicketMessage {
  const SupportTicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.messageType,
    required this.isInternal,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String ticketId;
  final String senderId;
  final String senderRole;
  final String content;
  final String messageType;
  final bool isInternal;
  final DateTime? readAt;
  final DateTime createdAt;

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessage(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      senderRole: json['sender_role'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      isInternal: json['is_internal'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isFromUser =>
      senderRole == 'user' || senderRole == 'driver';
  bool get isFromStaff => senderRole == 'admin';
}

class PagedTickets {
  const PagedTickets({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
  });

  final List<SupportTicket> items;
  final int total;
  final int page;
  final int perPage;
}

class PagedMessages {
  const PagedMessages({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
  });

  final List<SupportTicketMessage> items;
  final int total;
  final int page;
  final int perPage;
}
