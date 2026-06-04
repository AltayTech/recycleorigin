import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigin/core/logic/en_to_ar_number_convertor.dart';

import '../../../../core/models/customer.dart';
import '../../business/entities/message.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../../customer_feature/presentation/bloc/customer_info_bloc.dart';
import '../bloc/messages_bloc.dart';
import '../../../../core/widgets/drawer_or_back_leading.dart';
import '../widgets/message_reply_item.dart';
import 'messages_create_reply_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class MessageDetailScreen extends StatefulWidget {
  static const routeName = '/messageDetailScreen';

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  List<Message> messages = [];

  late Message message;

  late Customer customer;

  @override
  void didChangeDependencies() async {
    messages = context.read<MessagesBloc>().allMessagesDetail;

    if (_isInit) {
      message = ModalRoute.of(context)?.settings.arguments as Message;
      customer = context.read<CustomerInfoBloc>().customer;

      loadMessages();
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    bool isLogin = context.watch<AuthBloc>().isAuth;
    await context
        .read<MessagesBloc>()
        .getMessages(message.comment_post_ID, isLogin);
    messages = context.read<MessagesBloc>().allMessagesDetail;
    setState(() {
      _isLoading = false;
      print(_isLoading.toString());
    });
    print(_isLoading.toString());
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          '',
          style: TextStyle(
            color: context.appColors.scaffoldBackground,
            //fontFamily: 'Iransans',
            fontSize: textScaleFactor * 18.0,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            context.l10n.messageQuestionTitleLabel,
                            style: TextStyle(
                              color: context.appColors.subtitleColor,
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 15.0,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Spacer(),
                          Text(
                            EnArConvertor().replaceArNumber(
                                '${(DateTime.parse(message.comment_date)).hour}:${(DateTime.parse(message.comment_date)).minute}:${(DateTime.parse(message.comment_date)).second}'),
                            style: TextStyle(
                              color: context.appColors.subtitleColor,
                              //fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 15.0,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Text(
                              EnArConvertor().replaceArNumber(
                                  '${(DateTime.parse(message.comment_date)).year}/${(DateTime.parse(message.comment_date)).month}/${(DateTime.parse(message.comment_date)).day}'),
                              style: TextStyle(
                                color: context.appColors.subtitleColor,
                                //fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 15.0,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: deviceWidth,
                        child: Text(
                          message.subject,
                          style: TextStyle(
                            color: context.colors.onSurface,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 15.0,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Divider(),
                    Container(
                      height: deviceHeight * 0.8,
                      width: deviceWidth,
                      child: ListView.builder(
                        reverse: false,
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return MessageReplyItem(
                            message: messages[index],
                            isReply: messages[index].comment_agent != 'mobile',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? SpinKitFadingCircle(
                              itemBuilder: (BuildContext context, int index) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.appColors.subtitleColor,
                                  ),
                                );
                              },
                            )
                          : Container(
                              child: messages.isEmpty
                                  ? Center(
                                      child: Text(
                                      context.l10n.messageNoThreadYet,
                                      style: TextStyle(
                                        //fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 15.0,
                                      ),
                                    ))
                                  : Container())))
            ],
          ),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: Icon(
          Icons.reply,
          color: context.appColors.scaffoldBackground,
        ),
        onPressed: () {
          Navigator.pushNamed(context, MessageCreateReplyScreen.routeName,
              arguments: messages.last);
        },
      ),
    );
  }
}
