import 'dart:convert';

import 'package:flutter/material.dart';
import '../../business/entities/message.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/urls.dart';
import '../../../../core/utils/logger.dart';

class Messages with ChangeNotifier {
  List<Message> _allMessages = [];
  List<Message> _allMessagesDetail = [];
  late String _token;

  List<Message> get allMessages => _allMessages;

  List<Message> get allMessagesDetail => _allMessagesDetail;

  Future<void> createMessage(String subject, String content,
      String comment_post_ID, String parent_id, bool isLogin) async {
    AppLogger.debug('Creating message');
    try {
      if (isLogin) {
        final prefs = await SharedPreferences.getInstance();

        _token = prefs.getString('token')!;

        final url = comment_post_ID == '0'
            ? Urls.rootUrl +
                Urls.messageEndPoint +
                '?subject=$subject&content=$content'
            : Urls.rootUrl +
                Urls.messageEndPoint +
                '?subject=$subject&content=$content&comment_post_ID=$comment_post_ID&parent_id=$parent_id';

        final response = await post(Uri.parse(url), headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });

        final extractedData = json.decode(response.body);

        AppLogger.debug('Message created successfully');
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to create message',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }

  Future<void> getMessages(String commentPostId, bool isLogin) async {
    AppLogger.debug('Getting messages for comment post ID: $commentPostId');

    try {
      if (isLogin) {
        final prefs = await SharedPreferences.getInstance();

        _token = prefs.getString('token')!;

        final url = commentPostId == '0'
            ? Urls.rootUrl + Urls.messageEndPoint
            : Urls.rootUrl + Urls.messageEndPoint + '/$commentPostId';
        AppLogger.debug('Messages URL: $url');

        final response = await get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });

        final extractedData = json.decode(response.body) as List<dynamic>;
        AppLogger.debug('Loaded ${extractedData.length} messages');

        List<Message> messageList =
            extractedData.map((i) => Message.fromJson(i)).toList();

        commentPostId == '0'
            ? _allMessages = messageList
            : _allMessagesDetail = messageList;
      }
      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get messages',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }
}
