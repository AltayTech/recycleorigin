import 'package:flutter/widgets.dart';

import '../screens/coming_soon_screen.dart';
import 'app_config.dart';

/// Gates store UI until [AppConfig.enableStore] is turned on.
class StoreFeature {
  StoreFeature._();

  static Widget wrap(Widget child) {
    if (AppConfig.enableStore) {
      return child;
    }
    return const ComingSoonScreen();
  }
}
