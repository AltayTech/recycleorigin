import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

/// Immutable snapshot for waste catalog, cart, and collect requests.
class WastesState {
  WastesState({
    List<Waste>? wasteItems,
    List<WasteCart>? wasteCartItems,
    List<int>? wasteCartItemsId,
    this.token = '',
    List<RequestWasteItem>? collectItems,
    this.requestsListDirty = false,
    SearchDetail? searchDetails,
    this.requestWasteItem,
    this.selectedHours = '0',
    DateTime? selectedDay,
    this.searchEndPoint = '',
    this.searchKey = '',
    this.sPage = 1,
    this.sPerPage = 10,
    this.sOrder = 'desc',
    this.sOrderBy = 'date',
    this.sCategory,
  })  : wasteItems = wasteItems ?? const [],
        wasteCartItems = wasteCartItems ?? const [],
        wasteCartItemsId = wasteCartItemsId ?? const [],
        collectItems = collectItems ?? const [],
        searchDetails = searchDetails ?? SearchDetail(),
        selectedDay = selectedDay ?? DateTime.now();

  final List<Waste> wasteItems;
  final List<WasteCart> wasteCartItems;
  final List<int> wasteCartItemsId;
  final String token;
  final List<RequestWasteItem> collectItems;
  final bool requestsListDirty;
  final SearchDetail searchDetails;
  final RequestWasteItem? requestWasteItem;
  final String selectedHours;
  final DateTime selectedDay;
  final String searchEndPoint;
  final String searchKey;
  final int sPage;
  final int sPerPage;
  final String sOrder;
  final String sOrderBy;
  final Object? sCategory;

  WastesState copyWith({
    List<Waste>? wasteItems,
    List<WasteCart>? wasteCartItems,
    List<int>? wasteCartItemsId,
    String? token,
    List<RequestWasteItem>? collectItems,
    bool? requestsListDirty,
    SearchDetail? searchDetails,
    RequestWasteItem? requestWasteItem,
    String? selectedHours,
    DateTime? selectedDay,
    String? searchEndPoint,
    String? searchKey,
    int? sPage,
    int? sPerPage,
    String? sOrder,
    String? sOrderBy,
    Object? sCategory,
    bool clearRequestWasteItem = false,
  }) {
    return WastesState(
      wasteItems: wasteItems ?? this.wasteItems,
      wasteCartItems: wasteCartItems ?? this.wasteCartItems,
      wasteCartItemsId: wasteCartItemsId ?? this.wasteCartItemsId,
      token: token ?? this.token,
      collectItems: collectItems ?? this.collectItems,
      requestsListDirty: requestsListDirty ?? this.requestsListDirty,
      searchDetails: searchDetails ?? this.searchDetails,
      requestWasteItem: clearRequestWasteItem
          ? null
          : (requestWasteItem ?? this.requestWasteItem),
      selectedHours: selectedHours ?? this.selectedHours,
      selectedDay: selectedDay ?? this.selectedDay,
      searchEndPoint: searchEndPoint ?? this.searchEndPoint,
      searchKey: searchKey ?? this.searchKey,
      sPage: sPage ?? this.sPage,
      sPerPage: sPerPage ?? this.sPerPage,
      sOrder: sOrder ?? this.sOrder,
      sOrderBy: sOrderBy ?? this.sOrderBy,
      sCategory: sCategory ?? this.sCategory,
    );
  }
}
