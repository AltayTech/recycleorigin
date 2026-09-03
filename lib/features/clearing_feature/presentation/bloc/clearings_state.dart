import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/features/clearing_feature/business/entities/clearing.dart';

/// Immutable snapshot for clearing / delivery list.
class ClearingsState {
  ClearingsState({
    this.token = '',
    this.searchEndPoint = '',
    this.searchKey = '',
    this.sPage = 1,
    this.sPerPage = 10,
    this.sOrder = 'desc',
    this.sOrderBy = 'date',
    this.sCategory,
    List<Clearing>? deliveriesItems,
    SearchDetail? searchDetails,
    this.selectedHours = '0',
    DateTime? selectedDay,
  }) : deliveriesItems = deliveriesItems ?? const [],
       searchDetails = searchDetails ?? SearchDetail(),
       selectedDay = selectedDay ?? DateTime.now();

  final String token;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final Object? sCategory;
  final List<Clearing> deliveriesItems;
  final SearchDetail searchDetails;
  final String selectedHours;
  final DateTime selectedDay;

  ClearingsState copyWith({
    String? token,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    Object? sCategory,
    List<Clearing>? deliveriesItems,
    SearchDetail? searchDetails,
    String? selectedHours,
    DateTime? selectedDay,
  }) {
    return ClearingsState(
      token: token ?? this.token,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      sCategory: sCategory ?? this.sCategory,
      deliveriesItems: deliveriesItems ?? this.deliveriesItems,
      searchDetails: searchDetails ?? this.searchDetails,
      selectedHours: selectedHours ?? this.selectedHours,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}
