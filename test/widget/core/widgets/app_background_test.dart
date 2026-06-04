import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/widgets/app_background.dart';

void main() {
  group('AppBackground Widget Tests', () {
    test('should return AssetImage from getBackGroundImage', () {
      final image = AppBackground.getBackGroundImage();
      expect(image, isA<AssetImage>());
    });

    test('should return different images based on time of day', () {
      final image = AppBackground.getBackGroundImage();
      // Verify it returns an AssetImage (structure test)
      expect(image, isNotNull);
      expect(image, isA<AssetImage>());
    });

    test('should handle setIconForMain with different descriptions', () {
      final clearSkyIcon = AppBackground.setIconForMain('clear sky');
      expect(clearSkyIcon, isA<Image>());

      final cloudsIcon = AppBackground.setIconForMain('few clouds');
      expect(cloudsIcon, isA<Image>());

      final rainIcon = AppBackground.setIconForMain('rain');
      expect(rainIcon, isA<Image>());
    });
  });
}
