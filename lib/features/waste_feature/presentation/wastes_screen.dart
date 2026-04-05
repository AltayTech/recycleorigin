import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_drawer.dart';
import 'bloc/wastes_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';
import 'widgets/waste_item_wastes_screen.dart';

class WastesScreen extends StatefulWidget {
  static const routeName = '/wastesScreen';

  const WastesScreen({Key? key}) : super(key: key);

  @override
  _WastesScreenState createState() => _WastesScreenState();
}

class _WastesScreenState extends State<WastesScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  List<WasteCart> wasteCartItems = [];
  List<int> wasteCartItemsId = [];
  List<Waste> loadedWastes = [];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _loadData();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final wastesProvider = context.read<WastesBloc>();
      await wastesProvider.searchWastesItem();

      if (mounted) {
        setState(() {
          loadedWastes = wastesProvider.wasteItems;
          wasteCartItems = wastesProvider.wasteCartItems;
          wasteCartItemsId = wastesProvider.wasteCartItemsId;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Consider showing a snackbar here in a real app
      }
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive grid count: 2 for small phones, 3 for large phones/tablets, 4 for tablets
    final crossAxisCount = screenWidth < 360 ? 2 : (screenWidth > 600 ? 4 : 3);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        centerTitle: true,
        title: Text(
          context.l10n.wasteListTitle,
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: AppTheme.primary,
                size: 50.0,
              ),
            )
          : loadedWastes.isEmpty
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
                          padding: const EdgeInsets.only(top: 20, bottom: 100),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) {
                                final waste = loadedWastes[i];
                                return WasteItemWastesScreen(
                                  waste: waste,
                                  isSelected:
                                      wasteCartItemsId.contains(waste.id),
                                  onTap: () => _toggleSelection(waste),
                                );
                              },
                              childCount: loadedWastes.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: AppTheme.primary,
        icon: Icon(Icons.check, color: AppTheme.white),
        label: Text(
          context.l10n.doneLabel,
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            context.l10n.wasteSearchNoItemsMessage,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retryLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
