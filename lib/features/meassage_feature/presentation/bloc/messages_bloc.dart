import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:recycleorigin/core/constants/urls.dart';
import 'package:recycleorigin/core/utils/logger.dart';
import 'package:recycleorigin/features/meassage_feature/business/entities/message.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_event.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages loading and creating messages.
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(MessagesState()) {
    on<MessagesCreateRequested>(_onCreate);
    on<MessagesLoadRequested>(_onLoad);
  }

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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token')!;
        final url = event.commentPostId == '0'
            ? '${Urls.rootUrl}${Urls.messageEndPoint}'
                '?subject=${event.subject}&content=${event.content}'
            : '${Urls.rootUrl}${Urls.messageEndPoint}'
                '?subject=${event.subject}&content=${event.content}'
                '&comment_post_ID=${event.commentPostId}'
                '&parent_id=${event.parentId}';
        final response = await post(Uri.parse(url), headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        json.decode(response.body);
        AppLogger.debug('Message created successfully');
        emit(state.copyWith(token: token));
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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token')!;
        final url = event.commentPostId == '0'
            ? Urls.rootUrl + Urls.messageEndPoint
            : '${Urls.rootUrl}${Urls.messageEndPoint}/${event.commentPostId}';
        AppLogger.debug('Messages URL: $url');
        final response = await get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        final extractedData = json.decode(response.body) as List<dynamic>;
        AppLogger.debug('Loaded ${extractedData.length} messages');
        final messageList =
            extractedData.map((i) => Message.fromJson(i)).toList();
        if (event.commentPostId == '0') {
          emit(state.copyWith(allMessages: messageList, token: token));
        } else {
          emit(state.copyWith(allMessagesDetail: messageList, token: token));
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
