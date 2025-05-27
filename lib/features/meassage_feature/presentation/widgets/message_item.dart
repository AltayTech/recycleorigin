import 'package:flutter/material.dart';

import '../../business/entities/message.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/logic/en_to_ar_number_convertor.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    required this.message,
    required this.bgColor,
  });

  final Message message;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
        child: Container(
          height: deviceHeight * 0.25,
          color: AppTheme.white,
          child: LayoutBuilder(
            builder: (ctx, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: constraints.maxHeight * 0.20,
                  width: double.infinity,
                  color: AppTheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          EnArConvertor()
                              .replaceArNumber('${(
                            DateTime.parse(message.comment_date)
                          ).year}/${(
                            DateTime.parse(message.comment_date)
                          ).month}/${(
                            DateTime.parse(message.comment_date)
                          ).day}'),
                          style: TextStyle(
                            color: Colors.white,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 15.0,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          EnArConvertor().replaceArNumber(
                              '${(DateTime.parse(message.comment_date)).hour}:${(DateTime.parse(message.comment_date)).minute}:${(DateTime.parse(message.comment_date)).second}'),
                          style: TextStyle(
                            color: Colors.white,
                            //fontFamily: 'Iransans',
                            fontSize: textScaleFactor * 15.0,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0, top: 4),
                        child: Container(
                          height: constraints.maxHeight * 0.17,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              message.subject,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.black,
                                //fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: constraints.maxHeight * 0.40,
                          width: constraints.maxWidth * 0.9,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              message.comment_content,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                color: AppTheme.grey,
                                //fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 13.0,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
