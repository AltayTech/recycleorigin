import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';
import 'package:recycleorigin/l10n/app_localizations.dart';

import '../../../../core/models/region.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../../customer_feature/presentation/bloc/customer_info_bloc.dart';
import '../../../customer_feature/business/entities/city.dart';
import '../../../customer_feature/business/entities/country.dart';
import '../../../customer_feature/business/entities/province.dart';
import '../../business/entities/address.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/mapScreen';

  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _scrollController = ScrollController();

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  bool _isSaving = false;
  bool _isCountriesLoading = false;
  bool _isProvincesLoading = false;
  bool _isCitiesLoading = false;
  bool _isRegionsLoading = false;
  bool _isLocating = false;

  final osm.GeoPoint _defaultLocation =
      osm.GeoPoint(latitude: 38.074065, longitude: 46.312711);
  osm.GeoPoint? _selectedLocation;

  late osm.MapController _mapController;

  Country? _selectedCountry;
  Province? _selectedProvince;
  City? _selectedCity;
  Region? _selectedRegion;

  List<Country> _countries = <Country>[];
  List<Province> _provinces = <Province>[];
  List<City> _cities = <City>[];
  List<Region> _regions = <Region>[];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _mapController = osm.MapController(
      initPosition: _defaultLocation,
      areaLimit: osm.BoundingBox(
        east: 63.3,
        north: 39.8,
        south: 25.0,
        west: 44.0,
      ),
    );

    _loadCountries();
    _getCurrentLocation();
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _addressFocus.dispose();
    _scrollController.dispose();
    _animController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showInfoSnackBar(context.l10n.locationServicesDisabled);
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showInfoSnackBar(context.l10n.locationPermissionDenied);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showInfoSnackBar(context.l10n.locationPermissionDenied);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted && _selectedLocation == null) {
        final point = osm.GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        setState(() => _selectedLocation = point);
        await _mapController.changeLocation(point);
        await _mapController.setZoom(zoomLevel: 16);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _loadCountries() async {
    setState(() => _isCountriesLoading = true);
    try {
      await context.read<CustomerInfoBloc>().getCountries();
      if (!mounted) return;
      setState(() {
        _countries = context.read<CustomerInfoBloc>().countriesItems;
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.failedLoadCountriesRetry);
      }
    } finally {
      if (mounted) setState(() => _isCountriesLoading = false);
    }
  }

  Future<void> _loadProvinces(int countryId) async {
    setState(() => _isProvincesLoading = true);
    try {
      await context.read<CustomerInfoBloc>().getProvincesByCountry(countryId);
      if (!mounted) return;
      setState(() {
        _provinces = context.read<CustomerInfoBloc>().provincesItems;
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.failedLoadProvincesRetry);
      }
    } finally {
      if (mounted) setState(() => _isProvincesLoading = false);
    }
  }

  Future<void> _loadCities(int provinceId) async {
    setState(() => _isCitiesLoading = true);
    try {
      await context.read<CustomerInfoBloc>().getCities(provinceId);
      if (!mounted) return;
      setState(() {
        _cities = context.read<CustomerInfoBloc>().citiesItems;
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.failedLoadCitiesRetry);
      }
    } finally {
      if (mounted) setState(() => _isCitiesLoading = false);
    }
  }

  Future<void> _loadRegions(int cityId) async {
    setState(() => _isRegionsLoading = true);
    try {
      await context.read<AuthBloc>().retrieveRegionsByCity(cityId);
      if (!mounted) return;
      setState(() {
        _regions = context.read<AuthBloc>().regionItems;
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.failedLoadRegionsRetry);
      }
    } finally {
      if (mounted) setState(() => _isRegionsLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    try {
      final hasSelected = _selectedLocation != null;

      final point = await osm.showSimplePickerLocation(
        context: context,
        isDismissible: true,
        title: context.l10n.mapPickerTitle,
        textConfirmPicker: context.l10n.confirmLabel,
        textCancelPicker: context.l10n.cancelLabel,
        zoomOption: osm.ZoomOption(
          initZoom: 15,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        initPosition: hasSelected ? _selectedLocation : null,
        initCurrentUserPosition:
            hasSelected ? null : osm.UserTrackingOption(enableTracking: true),
      );

      if (point != null && mounted) {
        HapticFeedback.mediumImpact();
        setState(() => _selectedLocation = point);
        await _mapController.changeLocation(point);
        await _mapController.setZoom(zoomLevel: 16);
      }
    } catch (e) {
      debugPrint('Error picking location: $e');
    }
  }

  bool get _isFormComplete =>
      _selectedLocation != null &&
      _nameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _selectedCountry != null &&
      _selectedProvince != null &&
      _selectedCity != null &&
      _selectedRegion != null;

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToTop();
      return;
    }
    if (_selectedLocation == null) {
      _showErrorSnackBar(context.l10n.pleaseSelectLocationOnMap);
      _scrollToTop();
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    try {
      final authProvider = context.read<AuthBloc>();
      await authProvider.getAddresses();
      final currentAddresses = List<Address>.from(authProvider.addressItems);

      final newAddress = Address(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        region: Region(term_id: _selectedRegion!.term_id),
        latitude: _selectedLocation!.latitude.toString(),
        longitude: _selectedLocation!.longitude.toString(),
      );
      currentAddresses.add(newAddress);
      await authProvider.updateAddress(currentAddresses);

      if (mounted) {
        HapticFeedback.heavyImpact();
        _showSuccessSnackBar(context.l10n.addressSavedGoBack);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(context.l10n.failedSaveAddress);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: context.appColors.cardBackground, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: context.appColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: context.appColors.cardBackground, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: context.appColors.info,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: context.appColors.cardBackground, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;

    return Scaffold(
            body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(l10n),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MapSection(
                    mapController: _mapController,
                    selectedLocation: _selectedLocation,
                    isLocating: _isLocating,
                    onPickLocation: _pickLocation,
                    onMyLocation: _getCurrentLocation,
                    mapPreviewLabel: l10n.mapPreviewSemanticsLabel,
                  ),
                  _buildFormSection(l10n, size),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomSaveBar(l10n),
    );
  }

  SliverAppBar _buildSliverAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.appBarColor,
      foregroundColor: context.appColors.onHeroForeground,
      centerTitle: true,
      title: Text(
        l10n.newAddressTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildFormSection(AppLocalizations l10n, Size size) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.edit_note_rounded,
              title: l10n.mapScreenFormSection,
              subtitle: l10n.mapScreenFormHint,
            ),
            const SizedBox(height: 20),
            _buildStyledTextField(
              controller: _nameController,
              focusNode: _nameFocus,
              label: l10n.addressNameFieldLabel,
              hint: l10n.addressNameHintExample,
              icon: Icons.bookmark_outline_rounded,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_addressFocus),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),
            _CascadeDropdownGroup(
              countries: _countries,
              provinces: _provinces,
              cities: _cities,
              regions: _regions,
              selectedCountry: _selectedCountry,
              selectedProvince: _selectedProvince,
              selectedCity: _selectedCity,
              selectedRegion: _selectedRegion,
              isCountriesLoading: _isCountriesLoading,
              isProvincesLoading: _isProvincesLoading,
              isCitiesLoading: _isCitiesLoading,
              isRegionsLoading: _isRegionsLoading,
              onCountryChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                  _selectedProvince = null;
                  _selectedCity = null;
                  _selectedRegion = null;
                  _provinces = [];
                  _cities = [];
                  _regions = [];
                });
                _loadProvinces(country.id);
              },
              onProvinceChanged: (province) {
                setState(() {
                  _selectedProvince = province;
                  _selectedCity = null;
                  _selectedRegion = null;
                  _cities = [];
                  _regions = [];
                });
                _loadCities(province.id);
              },
              onCityChanged: (city) {
                setState(() {
                  _selectedCity = city;
                  _selectedRegion = null;
                  _regions = [];
                });
                _loadRegions(city.id);
              },
              onRegionChanged: (region) {
                setState(() => _selectedRegion = region);
              },
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              controller: _addressController,
              focusNode: _addressFocus,
              label: l10n.fullAddressFieldLabel,
              hint: l10n.fullAddressHint,
              icon: Icons.location_on_outlined,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: context.colors.onSurfaceVariant,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppTheme.primary.withOpacity(0.7)),
        filled: true,
        fillColor: context.appColors.cardBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBottomSaveBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 54,
          child: FilledButton(
            onPressed: _isSaving ? null : _saveAddress,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              disabledBackgroundColor: context.colors.outline,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: _isFormComplete ? 4 : 0,
              shadowColor: AppTheme.primary.withOpacity(0.4),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: context.appColors.onHeroForeground,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        l10n.saveAddressButton,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Full-width interactive map section with location controls.
class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.mapController,
    required this.selectedLocation,
    required this.isLocating,
    required this.onPickLocation,
    required this.onMyLocation,
    required this.mapPreviewLabel,
  });

  final osm.MapController mapController;
  final osm.GeoPoint? selectedLocation;
  final bool isLocating;
  final VoidCallback onPickLocation;
  final VoidCallback onMyLocation;
  final String mapPreviewLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final hasLocation = selectedLocation != null;
    final mapHeight = (size.height * 0.32).clamp(220.0, 380.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: _SectionHeader(
            icon: Icons.pin_drop_rounded,
            title: l10n.mapScreenLocationSection,
            subtitle: l10n.mapScreenLocationHint,
          ),
        ),
        Semantics(
          label: mapPreviewLabel,
          button: true,
          child: Container(
            height: mapHeight,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  AbsorbPointer(
                    absorbing: true,
                    child: osm.OSMFlutter(
                      controller: mapController,
                      osmOption: osm.OSMOption(
                        userTrackingOption: osm.UserTrackingOption(
                          enableTracking: false,
                          unFollowUser: false,
                        ),
                        zoomOption: osm.ZoomOption(
                          initZoom: 15,
                          minZoomLevel: 3,
                          maxZoomLevel: 19,
                          stepZoom: 1.0,
                        ),
                        showZoomController: false,
                        isPicker: true,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPickLocation,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                context.colors.shadow.withValues(alpha: 0.02),
                                context.colors.shadow.withValues(alpha: 0.12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -18),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 46,
                          color: hasLocation
                              ? AppTheme.primary
                              : context.appColors.subtitleColor,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: context.colors.shadow
                                  .withValues(alpha: 0.26),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        Expanded(
                          child: _MapActionChip(
                            icon: Icons.edit_location_alt_rounded,
                            label: hasLocation
                                ? l10n.tapToChangeLocation
                                : l10n.tapToSelectLocation,
                            onTap: onPickLocation,
                            isPrimary: !hasLocation,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _MapIconButton(
                          icon: Icons.my_location_rounded,
                          isLoading: isLocating,
                          onTap: onMyLocation,
                          tooltip: l10n.mapScreenMyLocation,
                        ),
                      ],
                    ),
                  ),
                  if (hasLocation)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _LocationBadge(location: selectedLocation!),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (hasLocation)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CoordinatesRow(location: selectedLocation!),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Compact badge showing "Location pinned" with a checkmark.
class _LocationBadge extends StatelessWidget {
  const _LocationBadge({required this.location});

  final osm.GeoPoint location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: context.appColors.cardBackground,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            context.l10n.locationPinned,
            style: TextStyle(
              color: context.appColors.cardBackground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle row beneath the map showing lat/lng.
class _CoordinatesRow extends StatelessWidget {
  const _CoordinatesRow({required this.location});

  final osm.GeoPoint location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.gps_fixed_rounded, size: 14, color: context.appColors.subtitleColor),
          const SizedBox(width: 6),
          Text(
            '${location.latitude.toStringAsFixed(5)}, '
            '${location.longitude.toStringAsFixed(5)}',
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.subtitleColor,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-shaped action chip on the map overlay.
class _MapActionChip extends StatelessWidget {
  const _MapActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppTheme.primary : context.appColors.cardBackground,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: context.colors.shadow.withValues(alpha: 0.26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? context.appColors.onHeroForeground : AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isPrimary ? context.appColors.onHeroForeground : context.colors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular icon button for "my location" on the map.
class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.isLoading,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.cardBackground,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: context.colors.shadow.withValues(alpha: 0.26),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip ?? '',
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  : Icon(icon, size: 20, color: AppTheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Section header with icon, title, and optional subtitle.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: context.colors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.subtitleColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Cascading dropdown group: Country > Province > City > Region.
///
/// Extracted as a separate widget to keep the form section clean.
class _CascadeDropdownGroup extends StatelessWidget {
  const _CascadeDropdownGroup({
    required this.countries,
    required this.provinces,
    required this.cities,
    required this.regions,
    required this.selectedCountry,
    required this.selectedProvince,
    required this.selectedCity,
    required this.selectedRegion,
    required this.isCountriesLoading,
    required this.isProvincesLoading,
    required this.isCitiesLoading,
    required this.isRegionsLoading,
    required this.onCountryChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
    required this.onRegionChanged,
  });

  final List<Country> countries;
  final List<Province> provinces;
  final List<City> cities;
  final List<Region> regions;

  final Country? selectedCountry;
  final Province? selectedProvince;
  final City? selectedCity;
  final Region? selectedRegion;

  final bool isCountriesLoading;
  final bool isProvincesLoading;
  final bool isCitiesLoading;
  final bool isRegionsLoading;

  final ValueChanged<Country> onCountryChanged;
  final ValueChanged<Province> onProvinceChanged;
  final ValueChanged<City> onCityChanged;
  final ValueChanged<Region> onRegionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        _StyledDropdown<Country>(
          label: l10n.countryFieldLabel,
          hint: l10n.selectCountryHint,
          icon: Icons.public_rounded,
          items: countries,
          selectedValue: selectedCountry,
          isLoading: isCountriesLoading,
          isEnabled: !isCountriesLoading,
          itemLabel: (c) => c.name,
          itemId: (c) => c.id.toString(),
          onChanged: (v) {
            if (v != null) onCountryChanged(v);
          },
          validator: (v) => v == null ? l10n.pleaseSelectCountry : null,
        ),
        const SizedBox(height: 14),
        _StyledDropdown<Province>(
          label: l10n.provinceFieldLabel,
          hint: l10n.selectProvinceHint,
          icon: Icons.location_city_rounded,
          items: provinces,
          selectedValue: selectedProvince,
          isLoading: isProvincesLoading,
          isEnabled: !isProvincesLoading && selectedCountry != null,
          itemLabel: (p) => p.name,
          itemId: (p) => p.id.toString(),
          onChanged: (v) {
            if (v != null) onProvinceChanged(v);
          },
          validator: (v) => v == null ? l10n.pleaseSelectProvince : null,
        ),
        const SizedBox(height: 14),
        _StyledDropdown<City>(
          label: l10n.cityFieldLabel,
          hint: l10n.selectCityHint,
          icon: Icons.location_pin,
          items: cities,
          selectedValue: selectedCity,
          isLoading: isCitiesLoading,
          isEnabled: !isCitiesLoading && selectedProvince != null,
          itemLabel: (c) => c.name,
          itemId: (c) => c.id.toString(),
          onChanged: (v) {
            if (v != null) onCityChanged(v);
          },
          validator: (v) => v == null ? l10n.pleaseSelectCity : null,
        ),
        const SizedBox(height: 14),
        _StyledDropdown<Region>(
          label: l10n.regionFieldLabel,
          hint: l10n.selectRegionHint,
          icon: Icons.map_rounded,
          items: regions,
          selectedValue: selectedRegion,
          isLoading: isRegionsLoading,
          isEnabled: !isRegionsLoading && selectedCity != null,
          itemLabel: (r) => r.name,
          itemId: (r) => r.term_id.toString(),
          onChanged: (v) {
            if (v != null) onRegionChanged(v);
          },
          validator: (v) => v == null ? l10n.pleaseSelectRegion : null,
        ),
      ],
    );
  }
}

/// Generic styled dropdown with loading state, validation,
/// and consistent visual treatment.
class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.selectedValue,
    required this.isLoading,
    required this.isEnabled,
    required this.itemLabel,
    required this.itemId,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String hint;
  final IconData icon;
  final List<T> items;
  final T? selectedValue;
  final bool isLoading;
  final bool isEnabled;
  final String Function(T) itemLabel;
  final String Function(T) itemId;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary.withOpacity(0.9),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.primary,
                  ),
                ),
              ],
              if (selectedValue != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  color: context.appColors.success,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
        DropdownButtonFormField<T>(
          value: selectedValue,
          dropdownColor: context.appColors.cardBackground,
          menuMaxHeight: 300,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(
            fontFamily: 'Iransans',
            color: context.colors.onSurface,
            fontSize: 14,
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
          validator: validator,
          hint: Text(
            hint,
            style: TextStyle(
              color: context.colors.onSurfaceVariant,
              fontFamily: 'Iransans',
              fontSize: 13,
            ),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primary.withOpacity(0.6)),
            filled: true,
            fillColor: isEnabled
                ? context.appColors.cardBackground
                : context.colors.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.error, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.appColors.divider),
            ),
          ),
        ),
      ],
    );
  }
}
