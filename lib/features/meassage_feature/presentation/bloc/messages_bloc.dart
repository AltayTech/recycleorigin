import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/meassage_feature/business/entities/message.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_event.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_state.dart';

/// Manages loading and creating messages.
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc(this._apiClient) : super(MessagesState()) {
    on<MessagesCreateRequested>(_onCreate);
    on<MessagesLoadRequested>(_onLoad);
  }

  final ApiClient _apiClient;

  List<Message> get allMessages => state.allMessages;
  List<Message> get allMessagesDetail => state.allMessagesDetail;

  Future<void> createMessage(
    String subject,
    String content,
    String commentPostId,
    String parentId,
    bool isLogin,
  ) {
    final c = Completer<void>();
    add(MessagesCreateRequested(
      subject,
      content,
      commentPostId,
      parentId,
      isLogin,
      completer: c,
    ));
    return c.future;
  }

  Future<void> getMessages(String commentPostId, bool isLogin) {
    final c = Completer<void>();
    add(MessagesLoadRequested(commentPostId, isLogin, completer: c));
    return c.future;
  }

  Future<void> _onCreate(
    MessagesCreateRequested event,
    Emitter<MessagesState> emit,
  ) async {
    AppLogger.debug('Creating message');
    try {
      if (event.isLogin) {
        final path = 'recycleorigin/v1${Urls.messageEndPoint}';
        final query = <String, dynamic>{
          'subject': event.subject,
          'content': event.content,
          if (event.commentPostId != '0') ...{
            'comment_post_ID': event.commentPostId,
            'parent_id': event.parentId,
          },
        };
        await _apiClient.post<dynamic>(path, queryParameters: query);
        AppLogger.debug('Message created successfully');
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to create message', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _onLoad(
    MessagesLoadRequested event,
    Emitter<MessagesState> emit,
  ) async {
    AppLogger.debug(
        'Getting messages for comment post ID: ${event.commentPostId}');
    try {
      if (event.isLogin) {
        final path = event.commentPostId == '0'
            ? 'recycleorigin/v1${Urls.messageEndPoint}'
            : 'recycleorigin/v1${Urls.messageEndPoint}/${event.commentPostId}';
        AppLogger.debug('Messages path: $path');
        final result = await _apiClient.get<List<dynamic>>(
          path,
          parser: (data) => data as List<dynamic>,
        );
        final extractedData = result.valueOrNull ?? <dynamic>[];
        AppLogger.debug('Loaded ${extractedData.length} messages');
        final messageList =
            extractedData.map((i) => Message.fromJson(i)).toList();
        if (event.commentPostId == '0') {
          emit(state.copyWith(allMessages: messageList));
        } else {
          emit(state.copyWith(allMessagesDetail: messageList));
        }
      }
      event.completer?.complete();
    } catch (e, st) {
      AppLogger.error('Failed to get messages', error: e, stackTrace: st);
      event.completer?.completeError(e, st);
      rethrow;
    }
  }
}
