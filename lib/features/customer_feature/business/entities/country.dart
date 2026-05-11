class Country {
  final int id;
  final String name;

  const Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> parsedJson) {
    return Country(
      id: (parsedJson['id'] as num?)?.toInt() ?? 0,
      name: (parsedJson['name'] as String?)?.trim() ?? '',
    );
  }
}
