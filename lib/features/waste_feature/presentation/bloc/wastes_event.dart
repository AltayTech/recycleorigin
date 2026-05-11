import 'dart:async';

import 'package:recycleorigin/features/waste_feature/business/entities/request_waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

/// Events for [WastesBloc].
sealed class WastesEvent {
  const WastesEvent();
}

class WastesSearchWastesItemRequested extends WastesEvent {
  const WastesSearchWastesItemRequested({this.completer});
  final Completer<void>? completer;
}

class WastesAddWasteCartRequested extends WastesEvent {
  const WastesAddWasteCartRequested(this.waste, this.weight, {this.completer});
  final Waste waste;
  final int weight;
  final Completer<void>? completer;
}

class WastesUpdateWasteCartRequested extends WastesEvent {
  const WastesUpdateWasteCartRequested(this.waste, this.quantity,
      {this.completer});
  final WasteCart waste;
  final int quantity;
  final Completer<void>? completer;
}

class WastesRemoveWasteCartRequested extends WastesEvent {
  const WastesRemoveWasteCartRequested(this.wasteId, {this.completer});
  final int wasteId;
  final Completer<void>? completer;
}

class WastesSendRequestRequested extends WastesEvent {
  const WastesSendRequestRequested(this.request, this.isLogin,
      {this.completer});
  final RequestWaste request;
  final bool isLogin;
  final Completer<void>? completer;
}

class WastesSelectedHoursSet extends WastesEvent {
  const WastesSelectedHoursSet(this.value);
  final String value;
}

class WastesSelectedDaySet extends WastesEvent {
  const WastesSelectedDaySet(this.value);
  final DateTime value;
}

class WastesSearchParamsChanged extends WastesEvent {
  const WastesSearchParamsChanged({
    this.searchKey,
    this.sPage,
    this.sPerPage,
    this.sOrder,
    this.sOrderBy,
    this.sCategory,
  });
  final String? searchKey;
  final int? sPage;
  final int? sPerPage;
  final String? sOrder;
  final String? sOrderBy;
  final Object? sCategory;
}

class WastesSearchBuilderApplied extends WastesEvent {
  const WastesSearchBuilderApplied();
}

class WastesSearchCollectItemsRequested extends WastesEvent {
  const WastesSearchCollectItemsRequested({this.completer});
  final Completer<void>? completer;
}

class WastesRetrieveCollectItemRequested extends WastesEvent {
  const WastesRetrieveCollectItemRequested(this.collectId, {this.completer});
  final int collectId;
  final Completer<void>? completer;
}

class WastesMarkRequestsListDirty extends WastesEvent {
  const WastesMarkRequestsListDirty();
}

class WastesSubmitDriverRatingRequested extends WastesEvent {
  const WastesSubmitDriverRatingRequested(
    this.collectId,
    this.score,
    this.comment, {
    this.completer,
  });
  final int collectId;
  final int score;
  final String comment;
  final Completer<void>? completer;
}
