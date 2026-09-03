import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_context_extensions.dart';
import '../../../core/widgets/drawer_or_back_leading.dart';
import 'bloc/wastes_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';
import 'widgets/waste_item_wastes_screen.dart';

class WastesScreen extends StatefulWidget {
  static const routeName = '/wastesScreen';

  const WastesScreen({super.key});

  @override
  State<WastesScreen> createState() => _WastesScreenState();
}

class _WastesScreenState extends State<WastesScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  List<WasteCart> wasteCartItems = [];
  List<int> wasteCartItemsId = [];
  List<Waste> loadedWastes = [];
  List<Waste> _filteredWastes = [];
  String _searchQuery = '';

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _loadData();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final wastesProvider = context.read<WastesBloc>();
      await wastesProvider.searchWastesItem();

      if (mounted) {
        setState(() {
          loadedWastes = wastesProvider.wasteItems;
          wasteCartItems = wastesProvider.wasteCartItems;
          wasteCartItemsId = wastesProvider.wasteCartItemsId;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredWastes = loadedWastes;
    } else {
      _filteredWastes = loadedWastes
          .where(
            (w) => w.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter();
    });
  }

  Future<void> _toggleSelection(Waste waste) async {
    final wastesProvider = context.read<WastesBloc>();

    if (wasteCartItemsId.contains(waste.id)) {
      await wastesProvider.removeWasteCart(waste.id);
    } else {
      await wastesProvider.addWasteCart(waste, 1);
    }

    if (!mounted) return;
    setState(() {
      wasteCartItemsId = wastesProvider.wasteCartItemsId;
      wasteCartItems = wastesProvider.wasteCartItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ? 2 : (screenWidth > 600 ? 4 : 3);
    final selectedCount = wasteCartItemsId.length;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        elevation: 0,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        centerTitle: true,
        title: Text(
          l10n.wasteListTitle,
          style: TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: _onSearchChanged,
            selectedCount: selectedCount,
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: SpinKitFadingCircle(
                      color: AppTheme.primary,
                      size: 50.0,
                    ),
                  )
                : _filteredWastes.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppTheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 0.82,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              delegate: SliverChildBuilderDelegate((ctx, i) {
                                final waste = _filteredWastes[i];
                                return WasteItemWastesScreen(
                                  waste: waste,
                                  isSelected: wasteCartItemsId.contains(
                                    waste.id,
                                  ),
                                  onTap: () => _toggleSelection(waste),
                                );
                              }, childCount: _filteredWastes.length),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _DoneButton(
        selectedCount: selectedCount,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.appColors.divider,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 48,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty
                ? l10n.wasteSearchNoItemsMessage
                : l10n.wasteSearchNoItemsMessage,
            style: TextStyle(
              fontSize: 17,
              color: context.appColors.subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              icon: Icon(Icons.clear_rounded, size: 18),
              label: Text(l10n.clearSearchLabel),
            ),
          ] else ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh_rounded),
              label: Text(l10n.retryLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.selectedCount,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: context.appColors.cardBackground,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: context.appColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.searchWasteHint,
                  hintStyle: TextStyle(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.colors.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: context.colors.onSurfaceVariant,
                            size: 18,
                          ),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          if (selectedCount > 0) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    selectedCount.toString(),
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.selectedCount, required this.onPressed});

  final int selectedCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppTheme.primary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(
        Icons.check_rounded,
        color: context.appColors.onHeroForeground,
      ),
      label: Row(
        children: [
          Text(
            l10n.doneLabel,
            style: TextStyle(
              color: context.appColors.onHeroForeground,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          if (selectedCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.appColors.onHeroForeground.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                selectedCount.toString(),
                style: TextStyle(
                  color: context.appColors.onHeroForeground,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
