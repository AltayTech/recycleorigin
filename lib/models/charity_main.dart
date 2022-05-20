import 'package:flutter/foundation.dart';

import '../models/search_detail.dart';
import 'charity.dart';

class CharityMain with ChangeNotifier {
  final SearchDetail charitiesDetail;

  final List<Charity> charities;

  CharityMain({this.charitiesDetail, this.charities});

  factory CharityMain.fromJson(Map<String, dynamic> parsedJson) {
    var charitiesList = parsedJson['data'] as List;
    List<Charity> charitiesRaw = new List<Charity>();

    charitiesRaw = charitiesList.map((i) => Charity.fromJson(i)).toList();

    return CharityMain(
      charitiesDetail: SearchDetail.fromJson(parsedJson['details']),
      charities: charitiesRaw,
    );
  }
}