import 'dart:async';

/// Events for [ArticlesBloc].
sealed class ArticlesEvent {
  const ArticlesEvent();
}

class ArticlesSearchParamsChanged extends ArticlesEvent {
  const ArticlesSearchParamsChanged({
    this.searchKey,
    this.sPage,
    this.sPerPage,
    this.sCategory,
  });
  final String? searchKey;
  final int? sPage;
  final int? sPerPage;
  final Object? sCategory;
}

class ArticlesSearchBuilderApplied extends ArticlesEvent {
  const ArticlesSearchBuilderApplied();
}

class ArticlesSearchItemRequested extends ArticlesEvent {
  const ArticlesSearchItemRequested({this.completer});
  final Completer<void>? completer;
}

class ArticlesRetrieveCategoryRequested extends ArticlesEvent {
  const ArticlesRetrieveCategoryRequested({this.completer});
  final Completer<void>? completer;
}

class ArticlesRetrieveItemRequested extends ArticlesEvent {
  const ArticlesRetrieveItemRequested(this.articleId, {this.completer});
  final int articleId;
  final Completer<void>? completer;
}
