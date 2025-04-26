import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../business/entities/article.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/article_detail_screen.dart';
import '../../../../core/logic/en_to_ar_number_convertor.dart';

class ArticleItemArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var heightDevice = MediaQuery.of(context).size.height;
    var widthDevice = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final article = Provider.of<Article>(context, listen: false);
    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Container(
      height: widthDevice * 0.35,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                ArticleDetailScreen.routeName,
                arguments: article.id,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                decoration: AppTheme.listItemBox,
                height: constraints.maxHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: constraints.maxHeight,
                        child: FadeInImage(
                          placeholder: AssetImage('assets/images/circle.gif'),
                          image: NetworkImage(article.featured_image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              article.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppTheme.black,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 14.0,
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    EnArConvertor().replaceArNumber(
                                      '${(DateTime.parse(article.post_date_gmt)).year}/${(DateTime.parse(article.post_date_gmt)).month}/${(DateTime.parse(article.post_date_gmt)).day}',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      height: 2,
                                      color: AppTheme.grey,
                                      fontFamily: 'Iransans',
                                      fontSize: textScaleFactor * 16.0,
                                    ),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        article.category[0].name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              AppTheme.black.withOpacity(0.5),
                                          fontFamily: 'Iransans',
                                          fontSize: textScaleFactor * 13.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
