import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recycleorigin/features/Charities/business/entities/charity.dart';
import 'package:recycleorigin/features/Charities/presentation/providers/charity_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/urls.dart';
import '../../../../core/models/search_detail.dart';
import '../../../../core/utils/logger.dart';

class Charities with ChangeNotifier {
  List<Charity> _charitiesItems = [];
  SearchDetail _searchDetails = SearchDetail(max_page: 1, total: 10);

  late Charity _item;

  String searchEndPoint = '';

  String searchKey = '';
  var _sPage = 1;
  var _sPerPage = 10;

  String _token = '';

  void searchBuilder() {
    if (!(searchKey == '')) {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?search=$searchKey';
      searchEndPoint = searchEndPoint + '&page=$_sPage&per_page=$_sPerPage';
    } else {
      searchEndPoint = '';

      searchEndPoint = searchEndPoint + '?page=$_sPage&per_page=$_sPerPage';
    }

    AppLogger.debug('Search endpoint: $searchEndPoint');
  }

  Future<void> searchCharitiesItem() async {
    AppLogger.debug('Searching charities');

    final url = Urls.rootUrl + Urls.charitiesEndPoint + searchEndPoint;
    AppLogger.debug('Charities search URL: $url');

    try {
      Dio dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await dio.get(url);
      AppLogger.debug('Charities search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        CharityMain charityMain = CharityMain.fromJson(response.data);

        _charitiesItems = charityMain.charities;
        _searchDetails = charityMain.charitiesDetail;
      } else {
        _charitiesItems = [];
      }

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search charities',
          error: error, stackTrace: stackTrace);
      throw error;
    }
  }

  // Future<void> searchCharitiesItem() async {
  //   debugPrint('searchCharityItem');
  //
  //   final url = Urls.rootUrl + Urls.charitiesEndPoint + searchEndPoint;
  //   debugPrint(url);
  //
  //   try {
  //     final response = await get(Uri.parse(url), headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json'
  //     });
  //     debugPrint(response.statusCode.toString());
  //     if (response.statusCode == 200) {
  //       // final extractedData = json.decode(response.body);
  //       // debugPrint(extractedData);
  //       CharityMain charityMain = CharityMain.fromJson(response.body);
  //
  //       _charitiesItems = charityMain.charities;
  //       _searchDetails = charityMain.charitiesDetail;
  //     } else {
  //       _charitiesItems = [];
  //     }
  //     notifyListeners();
  //   } catch (error) {
  //     debugPrint(error.toString());
  //     throw (error);
  //   }
  // }

  Future<void> retrieveCharityItem(int charityId) async {
    AppLogger.debug('Retrieving charity item: $charityId');

    final url = Urls.rootUrl + Urls.charitiesEndPoint + "/$charityId";
    AppLogger.debug('Charity URL: $url');

    try {
      Dio dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await dio.get(url);

      // If the response is JSON, Dio automatically parses it to a Map<String, dynamic>
      Charity charity = Charity.fromJson(response.data);
      AppLogger.debug('Charity retrieved: ${charity.id}');

      _item = charity;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to retrieve charity item',
          error: error, stackTrace: stackTrace);
      throw error;
    }

    notifyListeners();
  }

  // Future<void> retrieveCharityItem(int charityId) async {
  //   debugPrint('retrieveCharityItemvvvvv');
  //
  //   final url = Urls.rootUrl + Urls.charitiesEndPoint + "/$charityId";
  //   debugPrint(url);
  //
  //   try {
  //     final response = await get(Uri.parse(url), headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json'
  //     });
  //     // final extractedData = json.decode(response.body) as dynamic;
  //     // debugPrint(extractedData);
  //
  //     Charity charity = Charity.fromJson(response.body);
  //     debugPrint(charity.id.toString());
  //
  //     _item = charity;
  //   } catch (error) {
  //     debugPrint(error.toString());
  //     throw (error);
  //   }
  //   notifyListeners();
  // }

  List<Charity> get charitiesItems => _charitiesItems;

  set sPerPage(value) {
    _sPerPage = value;
  }

  set sPage(value) {
    _sPage = value;
  }

  SearchDetail get searchDetails => _searchDetails;

  get sPage => _sPage;

  get sPerPage => _sPerPage;

  Charity get item => _item;

  Future<void> sendCharityRequest(int charityId, String totalPrice) async {
    AppLogger.debug('Sending charity request for charity ID: $charityId');
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token')!;

      final url = Urls.rootUrl + Urls.charitiesEndPoint;
      AppLogger.debug('Charity request URL: $url');

      final response = await post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({
            "charity_id": charityId,
            "total_price": totalPrice,
          }));

      json.decode(response.body); // Validate response
      AppLogger.debug('Charity request sent successfully');

      notifyListeners();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to send charity request',
          error: error, stackTrace: stackTrace);
      throw (error);
    }
  }
}
