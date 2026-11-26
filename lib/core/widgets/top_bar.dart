import 'package:material_ui/material_ui.dart';

import 'curve_painter.dart';

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(height: 200.0),
      painter: CurvePainter(),
    );
  }
}
