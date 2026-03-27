import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/region.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth_feature/presentation/providers/authentication_provider.dart';
import '../../../customer_feature/presentation/providers/customer_info_provider.dart';
import '../../../customer_feature/business/entities/city.dart';
import '../../../customer_feature/business/entities/country.dart';
import '../../../customer_feature/business/entities/province.dart';
import '../../business/entities/address.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/mapScreen';

  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _labelToFieldGap = 6;
  static const double _fieldBlockGap = 14;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isCountriesLoading = false;
  bool _isProvincesLoading = false;
  bool _isCitiesLoading = false;
  bool _isRegionsLoading = false;

  // Default to Tabriz, Iran as in original code
  final osm.GeoPoint _defaultLocation =
      osm.GeoPoint(latitude: 38.074065, longitude: 46.312711);
  osm.GeoPoint? _selectedLocation;

  // Map Controller for the preview map
  late osm.MapController _mapController;

  Country? _selectedCountry;
  Province? _selectedProvince;
  City? _selectedCity;

  List<Country> _countries = <Country>[];
  List<Province> _provinces = <Province>[];
  List<City> _cities = <City>[];

  Region? _selectedRegion;
  List<Region> _regions = <Region>[];

  @override
  void initState() {
    super.initState();
    _mapController = osm.MapController(
      initPosition: _defaultLocation,
      areaLimit: osm.BoundingBox(
        east: 63.3,
        north: 39.8,
        south: 25.0,
        west: 44.0,
      ), // Approximate bounding box for Iran/Region
    );

    _loadCountries();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          // If user hasn't selected a location yet, update the map center
          if (_selectedLocation == null) {
            _mapController.changeLocation(osm.GeoPoint(
                latitude: position.latitude, longitude: position.longitude));
          }
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _loadCountries() async {
    setState(() => _isCountriesLoading = true);
    try {
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .getCountries();

      if (!mounted) return;

      final customerInfo =
          Provider.of<CustomerInfoProvider>(context, listen: false);

      setState(() {
        _countries = customerInfo.countriesItems;
        _isCountriesLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading countries: $e');
      if (!mounted) return;
      setState(() => _isCountriesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to load countries. Please check your internet connection.',
          ),
        ),
      );
    }
  }

  Future<void> _loadProvinces(int countryId) async {
    setState(() => _isProvincesLoading = true);
    try {
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .getProvincesByCountry(countryId);

      if (!mounted) return;
      final customerInfo =
          Provider.of<CustomerInfoProvider>(context, listen: false);

      setState(() {
        _provinces = customerInfo.provincesItems;
        _isProvincesLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading provinces: $e');
      if (!mounted) return;
      setState(() => _isProvincesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to load provinces. Please check your internet connection.',
          ),
        ),
      );
    }
  }

  Future<void> _loadCities(int provinceId) async {
    setState(() => _isCitiesLoading = true);
    try {
      await Provider.of<CustomerInfoProvider>(context, listen: false)
          .getCities(provinceId);

      if (!mounted) return;
      final customerInfo =
          Provider.of<CustomerInfoProvider>(context, listen: false);

      setState(() {
        _cities = customerInfo.citiesItems;
        _isCitiesLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
      if (!mounted) return;
      setState(() => _isCitiesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to load cities. Please check your internet connection.',
          ),
        ),
      );
    }
  }

  Future<void> _loadRegions(int cityId) async {
    setState(() => _isRegionsLoading = true);
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .retrieveRegionsByCity(cityId);

      if (!mounted) return;
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);

      setState(() {
        _regions = authProvider.regionItems;
        _isRegionsLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading regions: $e');
      if (!mounted) return;
      setState(() => _isRegionsLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to load regions. Please check your internet connection.',
          ),
        ),
      );
    }
  }

  Future<void> _pickLocation() async {
    try {
      // Determine initial configuration based on whether a location is already selected
      // We must strictly provide EITHER initPosition OR initCurrentUserPosition, not both (assertion error)
      final bool hasSelectedLocation = _selectedLocation != null;

      osm.GeoPoint? p = await osm.showSimplePickerLocation(
        context: context,
        isDismissible: true,
        title: "Select Address Location",
        textConfirmPicker: "Confirm",
        textCancelPicker: "Cancel",
        zoomOption: osm.ZoomOption(
          initZoom: 15,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        // If we have a selected location, start there (and disable auto-user-tracking init).
        // If not, we try to start at the user's current location.
        initPosition: hasSelectedLocation ? _selectedLocation : null,
        initCurrentUserPosition: hasSelectedLocation
            ? null
            : osm.UserTrackingOption(enableTracking: true),
      );

      if (p != null) {
        setState(() {
          _selectedLocation = p;
        });
        // Update the preview map
        await _mapController.changeLocation(p);
        await _mapController.setZoom(zoomLevel: 16);
      }
    } catch (e) {
      debugPrint("Error picking location: $e");
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country')),
      );
      return;
    }
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a province')),
      );
      return;
    }
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }
    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a region')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);

      // Ensure we have the latest list
      await authProvider.getAddresses();
      final currentAddresses = List<Address>.from(authProvider.addressItems);

      final newAddress = Address(
        name: _nameController.text,
        address: _addressController.text,
        region: Region(term_id: _selectedRegion!.term_id),
        latitude: _selectedLocation!.latitude.toString(),
        longitude: _selectedLocation!.longitude.toString(),
      );

      currentAddresses.add(newAddress);

      await authProvider.updateAddress(currentAddresses);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address saved successfully'),
            backgroundColor: AppTheme.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error saving address: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive layout adjustments if needed
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'New Address',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.appBarColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Map Preview Section
                _buildMapPreview(size),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("Location Details"),
                        const SizedBox(height: 16),

                        // Name Field
                        _buildTextField(
                          controller: _nameController,
                          label: "Address Name",
                          hint: "e.g., Home, Office",
                          icon: Icons.bookmark_border,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name for this address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location hierarchy: Country -> Province -> City -> Region
                        _buildLabeledField(
                          label: 'Country',
                          child: _buildCountryDropdown(),
                        ),
                        const SizedBox(height: _fieldBlockGap),
                        _buildLabeledField(
                          label: 'Province',
                          child: _buildProvinceDropdown(),
                        ),
                        const SizedBox(height: _fieldBlockGap),
                        _buildLabeledField(
                          label: 'City',
                          child: _buildCityDropdown(),
                        ),
                        const SizedBox(height: _fieldBlockGap),
                        _buildLabeledField(
                          label: 'Region',
                          child: _buildRegionDropdown(),
                        ),
                        const SizedBox(height: 16),

                        // Address Field
                        _buildTextField(
                          controller: _addressController,
                          label: "Full Address",
                          hint: "Street, Alley, Plaque...",
                          icon: Icons.location_on_outlined,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the full address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Save Address',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay (optional, if we want to block entire screen)
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(Size size) {
    return Container(
      height: size.height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          // The Map
          AbsorbPointer(
            // Disable direct interaction with map to prioritize scroll/tap to edit
            absorbing: true,
            child: osm.OSMFlutter(
              controller: _mapController,
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
                isPicker: true, // Show center marker
              ),
            ),
          ),

          // Overlay to tap and edit
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickLocation,
                child: Container(
                  color: Colors.black.withOpacity(
                      0.05), // Slight dim to indicate interactability
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_location_alt,
                              color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            _selectedLocation == null
                                ? "Tap to Select Location"
                                : "Tap to Change Location",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.h1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.h1,
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.primary,
              fontFamily: 'Iransans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: _labelToFieldGap),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.grey),
        filled: true,
        fillColor: AppTheme.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Clean look
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<Country>(
      key: ValueKey<String>(
        'country_${_selectedCountry?.id ?? 'none'}',
      ),
      initialValue: _selectedCountry,
      dropdownColor: AppTheme.white,
      menuMaxHeight: 320,
      isExpanded: true,
      style: TextStyle(
        fontFamily: 'Iransans',
        color: AppTheme.black,
        fontSize: 14,
      ),
      selectedItemBuilder: (BuildContext context) {
        return _countries.map((country) {
          final isSelected =
              _selectedCountry != null && _selectedCountry!.id == country.id;
          return Text(
            country.name,
            style: TextStyle(
              fontFamily: 'Iransans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.black,
            ),
          );
        }).toList();
      },
      items: _countries.map((country) {
        final isSelected =
            _selectedCountry != null && _selectedCountry!.id == country.id;
        return DropdownMenuItem<Country>(
          value: country,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.12)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.primary.withOpacity(0.12),
              ),
            ),
            child: Text(
              country.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.black,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: _isCountriesLoading
          ? null
          : (value) async {
              if (value == null) return;
              setState(() {
                _selectedCountry = value;
                _selectedProvince = null;
                _selectedCity = null;
                _selectedRegion = null;
                _provinces = <Province>[];
                _cities = <City>[];
                _regions = <Region>[];
              });
              await _loadProvinces(value.id);
            },
      validator: (value) => value == null ? 'Please select a country' : null,
      disabledHint: _isCountriesLoading
          ? Text(
              'Loading...',
              style: TextStyle(
                color: AppTheme.grey,
                fontFamily: 'Iransans',
              ),
            )
          : null,
      hint: Text(
        'Select country',
        style: TextStyle(
          color: AppTheme.grey,
          fontFamily: 'Iransans',
        ),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.public_rounded, color: AppTheme.grey),
        suffixIcon: _selectedCountry == null
            ? null
            : const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              ),
        filled: true,
        fillColor: AppTheme.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      icon: _isCountriesLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : Icon(
              Icons.arrow_drop_down,
              color: AppTheme.black,
            ),
    );
  }

  Widget _buildProvinceDropdown() {
    return DropdownButtonFormField<Province>(
      key: ValueKey<String>(
        'province_${_selectedProvince?.id ?? 'none'}',
      ),
      initialValue: _selectedProvince,
      dropdownColor: AppTheme.white,
      menuMaxHeight: 320,
      isExpanded: true,
      style: TextStyle(
        fontFamily: 'Iransans',
        color: AppTheme.black,
        fontSize: 14,
      ),
      selectedItemBuilder: (BuildContext context) {
        return _provinces.map((province) {
          final isSelected =
              _selectedProvince != null && _selectedProvince!.id == province.id;
          return Text(
            province.name,
            style: TextStyle(
              fontFamily: 'Iransans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.black,
            ),
          );
        }).toList();
      },
      items: _provinces.map((province) {
        final isSelected =
            _selectedProvince != null && _selectedProvince!.id == province.id;
        return DropdownMenuItem<Province>(
          value: province,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.12)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.primary.withOpacity(0.12),
              ),
            ),
            child: Text(
              province.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.black,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (_isProvincesLoading || _countries.isEmpty)
          ? null
          : (value) async {
              if (value == null) return;
              setState(() {
                _selectedProvince = value;
                _selectedCity = null;
                _selectedRegion = null;
                _cities = <City>[];
                _regions = <Region>[];
              });
              await _loadCities(value.id);
            },
      validator: (value) => value == null ? 'Please select a province' : null,
      disabledHint: _isProvincesLoading
          ? Text(
              'Loading...',
              style: TextStyle(
                color: AppTheme.grey,
                fontFamily: 'Iransans',
              ),
            )
          : null,
      hint: Text(
        'Select province',
        style: TextStyle(
          color: AppTheme.grey,
          fontFamily: 'Iransans',
        ),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.location_city_rounded, color: AppTheme.grey),
        suffixIcon: _selectedProvince == null
            ? null
            : const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              ),
        filled: true,
        fillColor: AppTheme.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      icon: _isProvincesLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : Icon(
              Icons.arrow_drop_down,
              color: AppTheme.black,
            ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<City>(
      key: ValueKey<String>(
        'city_${_selectedCity?.id ?? 'none'}',
      ),
      initialValue: _selectedCity,
      dropdownColor: AppTheme.white,
      menuMaxHeight: 320,
      isExpanded: true,
      style: TextStyle(
        fontFamily: 'Iransans',
        color: AppTheme.black,
        fontSize: 14,
      ),
      selectedItemBuilder: (BuildContext context) {
        return _cities.map((city) {
          final isSelected =
              _selectedCity != null && _selectedCity!.id == city.id;
          return Text(
            city.name,
            style: TextStyle(
              fontFamily: 'Iransans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.black,
            ),
          );
        }).toList();
      },
      items: _cities.map((city) {
        final isSelected =
            _selectedCity != null && _selectedCity!.id == city.id;
        return DropdownMenuItem<City>(
          value: city,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.12)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.primary.withOpacity(0.12),
              ),
            ),
            child: Text(
              city.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.black,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (_isCitiesLoading || _provinces.isEmpty)
          ? null
          : (value) async {
              if (value == null) return;
              setState(() {
                _selectedCity = value;
                _selectedRegion = null;
                _regions = <Region>[];
              });
              await _loadRegions(value.id);
            },
      validator: (value) => value == null ? 'Please select a city' : null,
      disabledHint: _isCitiesLoading
          ? Text(
              'Loading...',
              style: TextStyle(
                color: AppTheme.grey,
                fontFamily: 'Iransans',
              ),
            )
          : null,
      hint: Text(
        'Select city',
        style: TextStyle(
          color: AppTheme.grey,
          fontFamily: 'Iransans',
        ),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.location_pin, color: AppTheme.grey),
        suffixIcon: _selectedCity == null
            ? null
            : const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              ),
        filled: true,
        fillColor: AppTheme.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      icon: _isCitiesLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : Icon(
              Icons.arrow_drop_down,
              color: AppTheme.black,
            ),
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<Region>(
      key: ValueKey<String>(
        'region_${_selectedRegion?.term_id ?? 'none'}',
      ),
      initialValue: _selectedRegion,
      dropdownColor: AppTheme.white,
      menuMaxHeight: 320,
      isExpanded: true,
      style: TextStyle(
        fontFamily: 'Iransans',
        color: AppTheme.black,
        fontSize: 14,
      ),
      selectedItemBuilder: (BuildContext context) {
        return _regions.map((region) {
          final isSelected = _selectedRegion != null &&
              _selectedRegion!.term_id == region.term_id;
          return Text(
            region.name,
            style: TextStyle(
              fontFamily: 'Iransans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.black,
            ),
          );
        }).toList();
      },
      items: _regions.map((region) {
        final isSelected = _selectedRegion != null &&
            _selectedRegion!.term_id == region.term_id;
        return DropdownMenuItem<Region>(
          value: region,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.12)
                  : AppTheme.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.primary.withOpacity(0.12),
              ),
            ),
            child: Text(
              region.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.black,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: _isRegionsLoading
          ? null
          : (value) {
              setState(() {
                _selectedRegion = value;
              });
            },
      validator: (value) => value == null ? 'Please select a region' : null,
      disabledHint: _isRegionsLoading
          ? Text(
              'Loading...',
              style: TextStyle(
                color: AppTheme.grey,
                fontFamily: 'Iransans',
              ),
            )
          : null,
      hint: Text(
        'Select region',
        style: TextStyle(
          color: AppTheme.grey,
          fontFamily: 'Iransans',
        ),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.map, color: AppTheme.grey),
        suffixIcon: _selectedRegion == null
            ? null
            : const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              ),
        filled: true,
        fillColor: AppTheme.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      icon: _isRegionsLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ))
          : Icon(
              Icons.arrow_drop_down,
              color: AppTheme.black,
            ),
    );
  }
}
