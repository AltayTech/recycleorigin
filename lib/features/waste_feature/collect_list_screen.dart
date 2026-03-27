import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/request_waste_item.dart';

import '../../core/logic/en_to_ar_number_convertor.dart';
import '../../core/models/search_detail.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/main_drawer.dart';
import '../collect_feature/presentation/widgets/collect_item_collect_screen.dart';
import '../auth_feature/presentation/screens/login_screen.dart';
import 'presentation/providers/wastes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  // Using a local list to track items shown in UI
  final List<RequestWasteItem> _loadedRequests = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wastesProvider = Provider.of<Wastes>(context, listen: false);
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

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final wastesProvider = Provider.of<Wastes>(context, listen: false);
      wastesProvider.sPage = 1;
      wastesProvider.searchBuilder(); // Prepare search params if any

      await wastesProvider.searchCollectItems();

      _searchDetail = wastesProvider.searchDetails;

      // Update local list
      _loadedRequests.clear();
      _loadedRequests.addAll(await wastesProvider.CollectItems);
    } catch (error) {
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
      final wastesProvider = Provider.of<Wastes>(context, listen: false);
      wastesProvider.sPage = _page;

      await wastesProvider.searchCollectItems();

      final newItems = await wastesProvider.CollectItems;
      _loadedRequests.addAll(newItems);
      _searchDetail = wastesProvider.searchDetails;
    } catch (error) {
      debugPrint('Error loading more items: $error');
      _page--; // Revert page increment on failure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load more items. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
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
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        title: Text(
          'Request List',
          style: TextStyle(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: MainDrawer(),
      ),
      body: !isLogin ? _buildNotLoggedInView() : _buildContent(),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Please login to view your requests',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
            child: const Text('Login', style: TextStyle(color: Colors.white)),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
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
          if (_loadedRequests.isNotEmpty)
            SliverToBoxAdapter(child: _buildStatsRow()),
          _buildRequestsList(),
          if (_isLoading && _loadedRequests.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
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
          return const SizedBox(
            height: 100,
            child: Center(
              child:
                  Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildStatItem('Count:', _loadedRequests.length.toString()),
          const SizedBox(width: 12),
          _buildStatItem('Total:', _searchDetail.total.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            EnArConvertor().replaceArNumber(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
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
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No requests found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
