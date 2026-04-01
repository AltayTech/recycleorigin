import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buton_bottom.dart';
import '../../../core/widgets/main_drawer.dart';
import '../../auth_feature/presentation/bloc/auth_bloc.dart';
import 'pages/map_screen.dart';
import 'waste_request_date_screen.dart';
import 'widgets/address_item.dart';
import 'widgets/custom_dialog_enter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class AddressScreen extends StatefulWidget {
  static const routeName = '/address_screen';

  const AddressScreen({Key? key}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthBloc>().getAddresses();
    } catch (e) {
      // Handle error appropriately, maybe show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${context.l10n.failedLoadAddressesPrefix}$e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: context.l10n.signInRequiredTitle,
        buttonText: context.l10n.login,
        description: context.l10n.pleaseLoginToContinue,
        image: Image.asset('assets/images/main_page_request_ic.png'),
      ),
    );
  }

  void _handleContinue() {
    final authProvider = context.read<AuthBloc>();
    final isLogin = authProvider.isAuth;
    final selectedAddress = authProvider.selectedAddress;

    // Check if a valid address is selected (assuming valid address has a name)
    if (selectedAddress.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseSelectAddress),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isLogin) {
      _showLoginDialog();
    } else {
      Navigator.of(context).pushNamed(WasteRequestDateScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access provider once for the list
    final authProvider = context.watch<AuthBloc>();
    final addressList = authProvider.addressItems;
    final hasAddresses = addressList.isNotEmpty;
    // Check if selection is valid for button state
    final isSelectionValid = authProvider.selectedAddress.name.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          context.l10n.addressListTitle,
          style: TextStyle(color: AppTheme.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
      // Use extended FAB for better visibility and context
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(MapScreen.routeName);
        },
        backgroundColor: AppTheme.primary,
        icon: Icon(Icons.add_location_alt, color: AppTheme.white),
        label: Text(
          context.l10n.addNewAddressLabel,
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
      ),
      // Position it above the bottom navigation bar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Move the bottom action bar to the bottomNavigationBar property
      // This ensures the FAB floats above it correctly
      bottomNavigationBar: _buildBottomBar(context, isSelectionValid),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: AppTheme.primary,
                        size: 50.0,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAddresses,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildHeader(context),
                          ),
                          if (hasAddresses)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, i) {
                                    final address = addressList[i];
                                    final isSelected =
                                        authProvider.selectedAddress.name ==
                                            address.name;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: AddressItem(
                                        addressItem: address,
                                        isSelected: isSelected,
                                        onTap: () {
                                          authProvider.selectAddress(address);
                                          // Force rebuild to show selection if needed
                                        },
                                      ),
                                    );
                                  },
                                  childCount: addressList.length,
                                ),
                              ),
                            )
                          else
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            ),
                          // Add padding at the bottom so the last item isn't covered by the FAB
                          const SliverPadding(
                              padding: EdgeInsets.only(bottom: 80)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * 0.4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(bottom: BorderSide(width: 5, color: AppTheme.bg)),
      ),
      child: FadeInImage(
        placeholder: const AssetImage('assets/images/circle.gif'),
        image: const AssetImage('assets/images/address_page_header.png'),
        fit: BoxFit.contain,
        imageErrorBuilder: (context, error, stackTrace) {
          return const Center(
              child: Icon(Icons.map, size: 50, color: Colors.grey));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.location_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No addresses found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add a new address to get started',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: _handleContinue,
          child: ButtonBottom(
            width: double.infinity,
            height: 50,
            text: 'Continue',
            isActive: isActive,
          ),
        ),
      ),
    );
  }
}
