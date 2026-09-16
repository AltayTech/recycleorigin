import 'package:recycleorigin/features/meassage_feature/business/entities/message.dart';

/// Immutable snapshot for user messages.
class MessagesState {
  MessagesState({
    List<Message>? allMessages,
    List<Message>? allMessagesDetail,
    this.token = '',
  }) : allMessages = allMessages ?? const [],
       allMessagesDetail = allMessagesDetail ?? const [];

  final List<Message> allMessages;
  final List<Message> allMessagesDetail;
  final String token;

  MessagesState copyWith({
    List<Message>? allMessages,
    List<Message>? allMessagesDetail,
    String? token,
  }) {
    return MessagesState(
      allMessages: allMessages ?? this.allMessages,
      allMessagesDetail: allMessagesDetail ?? this.allMessagesDetail,
      token: token ?? this.token,
    );
  }
}
