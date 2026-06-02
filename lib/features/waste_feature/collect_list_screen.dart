import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';

import '../../core/logic/en_to_ar_number_convertor.dart';
import '../../core/models/search_detail.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context_extensions.dart';
import '../../core/widgets/drawer_or_back_leading.dart';
import '../collect_feature/presentation/widgets/collect_item_collect_screen.dart';
import '../auth_feature/presentation/screens/login_screen.dart';
import 'presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Sort options mapped to [WastesBloc] `order` / `orderby` query params.
enum _CollectSortOption {
  dateDesc('desc', 'date'),
  dateAsc('asc', 'date'),
  idDesc('desc', 'id'),
  idAsc('asc', 'id');

  const _CollectSortOption(this.order, this.orderBy);
  final String order;
  final String orderBy;
}

class CollectListScreen extends StatefulWidget {
  static const routeName = '/collectListScreen';

  const CollectListScreen({Key? key}) : super(key: key);

  @override
  _CollectListScreenState createState() => _CollectListScreenState();
}

class _CollectListScreenState extends State<CollectListScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isInit = true;
  bool _hasError = false;
  int _page = 1;
  SearchDetail _searchDetail = SearchDetail();

  /// Using a local list to track items shown in UI
  final List<RequestWasteItem> _loadedRequests = [];

  _CollectSortOption _sortOption = _CollectSortOption.dateDesc;

  /// Empty string means no filter. Otherwise a request status [Category.slug]
  /// supported by the API (`pending`, `in_progress`, …).
  String _filterCategorySlug = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wastesProvider = context.read<WastesBloc>();
    if (_isInit) {
      _loadInitialData();
      _isInit = false;
    } else if (wastesProvider.requestsListDirty) {
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _page < _searchDetail.max_page && !_hasError) {
        _loadMoreItems();
      }
    }
  }

  void _applySearchParams(WastesBloc bloc) {
    bloc.sOrder = _sortOption.order;
    bloc.sOrderBy = _sortOption.orderBy;
    bloc.sCategory = _filterCategorySlug;
    bloc.searchBuilder();
  }

  Future<void> _loadInitialData({bool resetScroll = false}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      _page = 1;
      final wastesProvider = context.read<WastesBloc>();
      wastesProvider.sPage = 1;
      _applySearchParams(wastesProvider);

      await wastesProvider.searchCollectItems();

      _searchDetail = wastesProvider.searchDetails;

      _loadedRequests.clear();
      _loadedRequests.addAll(wastesProvider.CollectItems);
      if (resetScroll && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    } on Exception catch (error) {
      debugPrint('Error loading initial data: $error');
      if (mounted) {
        setState(() => _hasError = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoading = true);
    try {
      _page++;
      final wastesProvider = context.read<WastesBloc>();
      wastesProvider.sPage = _page;
      _applySearchParams(wastesProvider);

      await wastesProvider.searchCollectItems();

      final newItems = wastesProvider.CollectItems;
      _loadedRequests.addAll(newItems);
      _searchDetail = wastesProvider.searchDetails;
    } catch (error) {
      debugPrint('Error loading more items: $error');
      _page--; // Revert page increment on failure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToLoadMoreItems),
            backgroundColor: context.appColors.danger,
            action: SnackBarAction(
              label: context.l10n.retryLabel,
              onPressed: _loadMoreItems,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<AuthBloc>().isAuth;

    return Scaffold(
      backgroundColor: context.appColors.scaffoldBackground,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          context.l10n.collectRequestListAppBarTitle,
          style: const TextStyle(color: AppTheme.appBarIconColor),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: !isLogin ? _buildNotLoggedInView() : _buildContent(),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            context.l10n.pleaseLoginToViewRequests,
            style: TextStyle(
              fontSize: 16,
              color: context.appColors.subtitleColor,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(LoginScreen.routeName),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(context.l10n.login,
                style: TextStyle(
                  color: context.appColors.onHeroForeground,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError && _loadedRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.somethingWentWrong,
              style: TextStyle(
              fontSize: 16,
              color: context.appColors.subtitleColor,
            ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: Icon(
                Icons.refresh,
                color: context.appColors.onHeroForeground,
              ),
              label: Text(context.l10n.retryLabel,
                  style: TextStyle(
                  color: context.appColors.onHeroForeground,
                )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderImage()),
          if (!(_isLoading && _loadedRequests.isEmpty))
            SliverToBoxAdapter(child: _buildListToolbar(context)),
          _buildRequestsList(),
          if (_isLoading && _loadedRequests.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Image.asset(
        'assets/images/collect_list_header.png',
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            height: 100,
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: context.appColors.subtitleColor,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Sort, filter, and result counts in one surfaced block (list header pattern).
  Widget _buildListToolbar(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colorScheme = theme.colorScheme;
    final hasFilter = _filterCategorySlug.isNotEmpty;
    final showSummary = _loadedRequests.isNotEmpty;

    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (showSummary) ...<Widget>[
                _buildToolbarSummary(context, theme),
                const SizedBox(height: 12),
              ],
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showSortSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      icon: Icon(
                        Icons.sort_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        _sortOptionLabel(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showFilterSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      icon: _FilterIconWithDot(
                        active: hasFilter,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        hasFilter
                            ? _filterSelectionLabel(l10n)
                            : l10n.collectListFilterLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarSummary(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;
    final colorScheme = theme.colorScheme;
    final loaded = EnArConvertor()
        .replaceArNumber(_loadedRequests.length.toString());
    final total = EnArConvertor().replaceArNumber(
      _searchDetail.total.toString(),
    );
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      height: 1.25,
    );
    final valueStyle = theme.textTheme.titleSmall?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w700,
      height: 1.25,
    );
    final sepStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
    );

    final semantic = StringBuffer()
      ..write('${l10n.listCountSummaryPrefix} $loaded')
      ..write(', ${l10n.cartTotalSummaryPrefix} $total');

    return Semantics(
      label: semantic.toString(),
      container: true,
      child: ExcludeSemantics(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: l10n.listCountSummaryPrefix,
                  style: labelStyle,
                ),
                TextSpan(text: ' ', style: labelStyle),
                TextSpan(text: loaded, style: valueStyle),
                TextSpan(text: ' \u00b7 ', style: sepStyle),
                TextSpan(
                  text: l10n.cartTotalSummaryPrefix,
                  style: labelStyle,
                ),
                TextSpan(text: ' ', style: labelStyle),
                TextSpan(text: total, style: valueStyle),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  String _sortOptionLabel(AppLocalizations l10n) {
    return switch (_sortOption) {
      _CollectSortOption.dateDesc => l10n.collectListSortNewestFirst,
      _CollectSortOption.dateAsc => l10n.collectListSortOldestFirst,
      _CollectSortOption.idDesc => l10n.collectListSortIdHighToLow,
      _CollectSortOption.idAsc => l10n.collectListSortIdLowToHigh,
    };
  }

  String _filterSelectionLabel(AppLocalizations l10n) {
    return switch (_filterCategorySlug) {
      'pending' => l10n.pendingLabel,
      'in_progress' => l10n.statusInProgress,
      'picked_up' => l10n.statusPickedUp,
      'collected' => l10n.statusCollected,
      'cancelled' => l10n.statusCancelled,
      _ => l10n.collectListFilterLabel,
    };
  }

  Future<void> _showSortSheet(BuildContext context) async {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<_CollectSortOption>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        Widget row(_CollectSortOption o, String label) {
          final selected = _sortOption == o;
          return ListTile(
            title: Text(label),
            trailing: selected
                ? Icon(Icons.check_rounded, color: colorScheme.primary)
                : null,
            onTap: () => Navigator.pop(ctx, o),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  l10n.collectListSortSheetTitle,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              row(_CollectSortOption.dateDesc, l10n.collectListSortNewestFirst),
              row(_CollectSortOption.dateAsc, l10n.collectListSortOldestFirst),
              row(_CollectSortOption.idDesc, l10n.collectListSortIdHighToLow),
              row(_CollectSortOption.idAsc, l10n.collectListSortIdLowToHigh),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked == null || !mounted || picked == _sortOption) return;
    setState(() => _sortOption = picked);
    await _loadInitialData(resetScroll: true);
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        Widget row(String slug, String label) {
          final selected = _filterCategorySlug == slug;
          return ListTile(
            title: Text(label),
            trailing: selected
                ? Icon(Icons.check_rounded, color: colorScheme.primary)
                : null,
            onTap: () => Navigator.pop(ctx, slug),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  l10n.collectListFilterSheetTitle,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              row('', l10n.collectListFilterAll),
              row('pending', l10n.pendingLabel),
              row('in_progress', l10n.statusInProgress),
              row('picked_up', l10n.statusPickedUp),
              row('collected', l10n.statusCollected),
              row('cancelled', l10n.statusCancelled),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked == null || !mounted) return;
    if (picked == _filterCategorySlug) return;
    setState(() => _filterCategorySlug = picked);
    await _loadInitialData(resetScroll: true);
  }

  Widget _buildRequestsList() {
    if (_isLoading && _loadedRequests.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: SpinKitFadingCircle(
            color: AppTheme.primary,
            size: 50.0,
          ),
        ),
      );
    }

    if (_loadedRequests.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: context.appColors.subtitleColor,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.collectListNoRequestsMessage,
                style: TextStyle(
              fontSize: 16,
              color: context.appColors.subtitleColor,
            ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: ChangeNotifierProvider.value(
              value: _loadedRequests[index],
              child: CollectItemCollectsScreen(),
            ),
          );
        },
        childCount: _loadedRequests.length,
      ),
    );
  }
}

/// Filter icon with a small indicator when a filter is active (Material 3 cue).
class _FilterIconWithDot extends StatelessWidget {
  const _FilterIconWithDot({
    required this.active,
    required this.color,
  });

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(Icons.filter_list_rounded, size: 20, color: color),
        if (active)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
