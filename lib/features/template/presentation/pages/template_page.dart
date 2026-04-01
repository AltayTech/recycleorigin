import 'package:flutter/material.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class TemplatePage extends StatelessWidget {
  const TemplatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(context.l10n.templatePageTitle),
      ),
    );
  }
}
