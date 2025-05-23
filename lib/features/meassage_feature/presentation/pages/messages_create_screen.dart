import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../business/entities/message.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_feature/presentation/providers/authentication_provider.dart';
import '../providers/messages.dart';
import '../../../../core/widgets/main_drawer.dart';

class MessageCreateScreen extends StatefulWidget {
  static const routeName = '/messageCreateScreen';

  @override
  _MessageCreateScreenState createState() => _MessageCreateScreenState();
}

class _MessageCreateScreenState extends State<MessageCreateScreen> {
  var _isLoading = false;
  var _isInit = true;

  List<Message> messages = [];

  List<String> aboutInfotitle = [];

  List<String> aboutInfoContent = [];

  final contentTextController = TextEditingController(text: '');
  final subjectTextController = TextEditingController(text: '');

  late bool isLogin;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      contentTextController.text = '';
      subjectTextController.text = '';

      isLogin = Provider.of<AuthenticationProvider>(context).isAuth;
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    contentTextController.dispose();
    subjectTextController.dispose();

    super.dispose();
  }

  Future<void> createMessages() async {
    setState(() {
      _isLoading = true;
    });

    debugPrint('subjectTextController.text');
    debugPrint(subjectTextController.text);
    debugPrint(' contentTextController.text');
    debugPrint(contentTextController.text);

    await Provider.of<Messages>(context, listen: false)
        .createMessage(
      subjectTextController.text,
      contentTextController.text,
      '0',
      '0',
      isLogin,
    )
        .then((value) async {
      await Provider.of<Messages>(context, listen: false)
          .getMessages('0', isLogin);
      Navigator.of(context).pop();
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New message',
          style: TextStyle(
            color: AppTheme.bg,
            fontFamily: 'Iransans',
            fontSize: textScaleFactor * 18.0,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: deviceHeight * 0.9,
            color: AppTheme.primary.withOpacity(0.05),
            child: Stack(
              children: <Widget>[
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 30,
                              bottom: 8.0,
                            ),
                            child: Text(
                              'Please enter your question. Our colleagues will review your question and send the answer to you.',
                              style: TextStyle(
                                color: AppTheme.black,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 15.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: Container(
//                                  height: deviceHeight * 0.1,
                              child: TextField(
                                controller: subjectTextController,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'Iransans',
                                  fontSize: textScaleFactor * 15.0,
                                ),
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppTheme.bg,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppTheme.bg,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 15.0,
                                  ),
                                  labelText: 'Title',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: Container(
                              height: deviceHeight * 0.6,
                              child: TextField(
                                maxLines: 10,
                                controller: contentTextController,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'Iransans',
                                  fontSize: textScaleFactor * 15.0,
                                ),
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppTheme.bg,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppTheme.bg,
                                    ),
                                  ),
                                  alignLabelWithHint: true,
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 15.0,
                                  ),
                                  labelText: 'write your message',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                    color: index.isEven
                                        ? AppTheme.h1
                                        : AppTheme.h1,
                                  ),
                                );
                              },
                            )
                          : Container()),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          createMessages();
        },
        backgroundColor: AppTheme.primary,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ),
    );
  }
}
