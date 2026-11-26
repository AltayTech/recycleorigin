import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps `<a>` links in [HtmlWidget] on the app's link color.
///
/// `flutter_widget_from_html_core` still reads its link color from the legacy
/// `package:flutter/material.dart` `Theme`, which cannot see the app's
/// `material_ui` theme and falls back to the default Material palette. Pass
/// the result as `customStylesBuilder` until the package moves to
/// `material_ui`.
CustomStylesBuilder htmlLinkStyles(Color linkColor) {
  final rgb = linkColor.toARGB32() & 0xFFFFFF;
  final hex = '#${rgb.toRadixString(16).padLeft(6, '0')}';
  return (element) =>
      element.localName == 'a' ? <String, String>{'color': hex} : null;
}
