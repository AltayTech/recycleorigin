import 'package:flutter/widgets.dart';

extension NumExtension on num? {
  Widget get verticalSpace => this == 0
      ? SizedBox.shrink()
      : SizedBox(
          height: this?.toDouble(),
        );

  Widget get horizontalSpace => this == 0
      ? SizedBox.shrink()
      : SizedBox(
          width: this?.toDouble(),
        );
}
