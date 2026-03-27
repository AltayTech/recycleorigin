import 'dart:async';

/// Events for [ClearingsBloc].
sealed class ClearingsEvent {
  const ClearingsEvent();
}

class ClearingsSearchParamsChanged extends ClearingsEvent {
  const ClearingsSearchParamsChanged({
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

class ClearingsSearchBuilderApplied extends ClearingsEvent {
  const ClearingsSearchBuilderApplied();
}

class ClearingsSearchItemsRequested extends ClearingsEvent {
  const ClearingsSearchItemsRequested({this.completer});
  final Completer<void>? completer;
}

class ClearingsSelectedHoursSet extends ClearingsEvent {
  const ClearingsSelectedHoursSet(this.value);
  final String value;
}

class ClearingsSelectedDaySet extends ClearingsEvent {
  const ClearingsSelectedDaySet(this.value);
  final DateTime value;
}
