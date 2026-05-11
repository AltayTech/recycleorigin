import 'dart:io';

import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/core/models/order.dart';
import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/models/status.dart';
import 'package:recycleorigin/core/models/transaction.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/city.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/country.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/province.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/personal_data.dart';
import 'package:recycleorigin/features/store_feature/business/entities/belongs.dart';
import 'package:recycleorigin/features/store_feature/business/entities/order_details.dart';
import 'package:recycleorigin/features/store_feature/business/entities/shop.dart';

Customer buildEmptyCustomer() => Customer(
      personalData: PersonalData(
        first_name: '',
        last_name: '',
        email: '',
        ostan: '',
        city: '',
        postcode: '',
        phone: '',
      ),
      money: '0',
    );

OrderDetails buildEmptyOrderDetails() => OrderDetails(
      id: 0,
      total_cost: '',
      shenaseh: '',
      order_register_date: '',
      number_of_products: 0,
      products: const [],
      order_status: '',
      order_status_slug: '',
      pay_type: '',
      pay_type_slug: '',
      pish: '',
      pay_status: '',
      pay_status_slug: '',
    );

Transaction buildEmptyTransaction() => Transaction(
      transaction_type: Status(),
      belongs: Belongs(id: 0, name: ''),
    );

class CustomerInfoState {
  CustomerInfoState({
    this.payUrl = '',
    this.currentOrderId = 0,
    Shop? shop,
    Customer? customer,
    List<Order>? orders,
    OrderDetails? order,
    this.searchEndPoint = '',
    this.searchKey = '',
    this.sPage = 1,
    this.sPerPage = 10,
    this.sOrder = 'desc',
    this.sOrderBy = 'date',
    List<Transaction>? transactionItems,
    SearchDetail? searchDetails,
    Transaction? transactionItem,
    List<Province>? provincesItems,
    List<Country>? countriesItems,
    List<City>? citiesItems,
    List<Status>? typesItems,
    List<File>? chequeImageList,
  })  : shop = shop ?? Shop(),
        customer = customer ?? buildEmptyCustomer(),
        orders = orders ?? <Order>[],
        order = order ?? buildEmptyOrderDetails(),
        transactionItems = transactionItems ?? <Transaction>[],
        searchDetails = searchDetails ?? SearchDetail(),
        transactionItem = transactionItem ?? buildEmptyTransaction(),
        provincesItems = provincesItems ?? <Province>[],
        countriesItems = countriesItems ?? <Country>[],
        citiesItems = citiesItems ?? <City>[],
        typesItems = typesItems ?? <Status>[],
        chequeImageList = chequeImageList ?? <File>[];

  final String payUrl;
  final int currentOrderId;
  final Shop shop;
  final Customer customer;
  final List<Order> orders;
  final OrderDetails order;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final List<Transaction> transactionItems;
  final SearchDetail searchDetails;
  final Transaction transactionItem;
  final List<Province> provincesItems;
  final List<Country> countriesItems;
  final List<City> citiesItems;
  final List<Status> typesItems;
  final List<File> chequeImageList;

  CustomerInfoState copyWith({
    String? payUrl,
    int? currentOrderId,
    Shop? shop,
    Customer? customer,
    List<Order>? orders,
    OrderDetails? order,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    List<Transaction>? transactionItems,
    SearchDetail? searchDetails,
    Transaction? transactionItem,
    List<Province>? provincesItems,
    List<Country>? countriesItems,
    List<City>? citiesItems,
    List<Status>? typesItems,
    List<File>? chequeImageList,
  }) {
    return CustomerInfoState(
      payUrl: payUrl ?? this.payUrl,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      shop: shop ?? this.shop,
      customer: customer ?? this.customer,
      orders: orders ?? this.orders,
      order: order ?? this.order,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      transactionItems: transactionItems ?? this.transactionItems,
      searchDetails: searchDetails ?? this.searchDetails,
      transactionItem: transactionItem ?? this.transactionItem,
      provincesItems: provincesItems ?? this.provincesItems,
      countriesItems: countriesItems ?? this.countriesItems,
      citiesItems: citiesItems ?? this.citiesItems,
      typesItems: typesItems ?? this.typesItems,
      chequeImageList: chequeImageList ?? this.chequeImageList,
    );
  }
}
