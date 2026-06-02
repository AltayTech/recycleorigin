import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';

class DotLoadingWidget extends StatelessWidget {
  const DotLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.halfTriangleDot(
        size: 50,
        color: context.appColors.subtitleColor,
      ),
    );
  }
}
