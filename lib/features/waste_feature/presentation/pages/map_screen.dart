import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/region.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_feature/presentation/providers/authentication_provider.dart';
import '../../business/entities/address.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/mapScreen';

  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isRegionsLoading = false;

  // Default to Tabriz, Iran as in original code
  final osm.GeoPoint _defaultLocation =
      osm.GeoPoint(latitude: 38.074065, longitude: 46.312711);
  osm.GeoPoint? _selectedLocation;

  // Map Controller for the preview map
  late osm.MapController _mapController;

  Region? _selectedRegion;
  List<Region> _regions = [];

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

    _loadRegions();
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

  Future<void> _loadRegions() async {
    setState(() {
      _isRegionsLoading = true;
    });
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .retrieveRegionList();
      if (mounted) {
        setState(() {
          _regions = Provider.of<AuthenticationProvider>(context, listen: false)
              .regionItems;
          _isRegionsLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading regions: $e");
      if (mounted) {
        setState(() {
          _isRegionsLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load regions. Please check your internet connection.')),
        );
      }
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

                        // Region Dropdown
                        _buildRegionDropdown(),
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

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<Region>(
      initialValue: _selectedRegion,
      items: _regions.map((region) {
        return DropdownMenuItem<Region>(
          value: region,
          child: Text(region.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRegion = value;
        });
      },
      validator: (value) => value == null ? 'Please select a region' : null,
      decoration: InputDecoration(
        labelText: 'Region',
        prefixIcon: Icon(Icons.map, color: AppTheme.grey),
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
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(Icons.arrow_drop_down),
    );
  }
}
