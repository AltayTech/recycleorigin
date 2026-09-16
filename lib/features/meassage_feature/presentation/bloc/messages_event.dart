import 'dart:async';

/// Events for [MessagesBloc].
sealed class MessagesEvent {
  const MessagesEvent();
}

class MessagesCreateRequested extends MessagesEvent {
  const MessagesCreateRequested(
    this.subject,
    this.content,
    this.commentPostId,
    this.parentId,
    this.isLogin, {
    this.completer,
  });
  final String subject;
  final String content;
  final String commentPostId;
  final String parentId;
  final bool isLogin;
  final Completer<void>? completer;
}

class MessagesLoadRequested extends MessagesEvent {
  const MessagesLoadRequested(
    this.commentPostId,
    this.isLogin, {
    this.completer,
  });
  final String commentPostId;
  final bool isLogin;
  final Completer<void>? completer;
}
