import 'package:material_ui/material_ui.dart';

class Feature with ChangeNotifier {
  final String feature;

  Feature({required this.feature});

  factory Feature.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return Feature(feature: '');
    }
    return Feature(feature: raw['feature'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'feature': feature};
  }
}
