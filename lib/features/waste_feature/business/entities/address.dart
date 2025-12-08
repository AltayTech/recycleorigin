import '../../../../core/models/region.dart';

/// Address entity representing a user's address
/// 
/// This is an immutable value object following domain-driven design principles.
/// Entities should not extend ChangeNotifier - that's the responsibility of
/// the presentation layer (providers/view models).
class Address {
  final String name;
  final String address;
  final Region region;
  final String latitude;
  final String longitude;

  const Address({
    this.name = '',
    this.address = '',
    required this.region,
    this.latitude = '0.0',
    this.longitude = '0.0',
  });

  /// Creates an Address from JSON
  /// 
  /// Handles null values gracefully with default values
  factory Address.fromJson(Map<String, dynamic> parsedJson) {
    return Address(
      name: parsedJson['name'] as String? ?? '',
      address: parsedJson['address'] as String? ?? '',
      region: parsedJson['region'] != null
          ? Region.fromJson(parsedJson['region'] as Map<String, dynamic>)
          : Region(term_id: 0, name: '', collect_hour: []),
      latitude: parsedJson['latitude']?.toString() ?? '0.0',
      longitude: parsedJson['longitude']?.toString() ?? '0.0',
    );
  }

  /// Converts Address to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'region': region.toJson(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Creates a copy of this address with updated fields
  Address copyWith({
    String? name,
    String? address,
    Region? region,
    String? latitude,
    String? longitude,
  }) {
    return Address(
      name: name ?? this.name,
      address: address ?? this.address,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          address == other.address &&
          region == other.region &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode =>
      name.hashCode ^
      address.hashCode ^
      region.hashCode ^
      latitude.hashCode ^
      longitude.hashCode;

  @override
  String toString() {
    return 'Address(name: $name, address: $address, region: ${region.name}, '
        'latitude: $latitude, longitude: $longitude)';
  }
}
