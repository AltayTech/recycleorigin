import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';

class InfoEditItem extends StatelessWidget {
  const InfoEditItem({
    super.key,
    required this.title,
    required this.controller,
    required this.keybordType,
    required this.bgColor,
    required this.iconColor,
    required this.thisFocusNode,
    required this.newFocusNode,
    this.maxLine = 1,
    required this.fieldHeight,
    this.readOnly = false,
    this.validator,
    this.helperText,
    this.textInputAction,
  });

  final String title;
  final TextEditingController controller;
  final TextInputType keybordType;
  final int maxLine;
  final Color bgColor;
  final Color iconColor;
  final double fieldHeight;
  final FocusNode newFocusNode;
  final FocusNode thisFocusNode;
  final bool readOnly;
  final String? Function(String?)? validator;
  final String? helperText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: deviceWidth * 0.8,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '$title : ',
                  style: TextStyle(
                    color: AppTheme.h1,
                    fontSize: textScaleFactor * 14.0,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                height: fieldHeight,
                child: TextFormField(
                  maxLines: maxLine,
                  keyboardType: keybordType,
                  readOnly: readOnly,
                  enableInteractiveSelection: !readOnly,
                  validator: validator ??
                      (String? value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.fieldRequiredValidation;
                        }
                        return null;
                      },
                  style: TextStyle(
                    color: readOnly ? AppTheme.grey : AppTheme.h1,
                    fontSize: textScaleFactor * 14.0,
                  ),
                  onFieldSubmitted: readOnly
                      ? null
                      : (_) => FocusScope.of(context).requestFocus(
                            newFocusNode,
                          ),
                  focusNode: thisFocusNode,
                  textInputAction:
                      textInputAction ?? TextInputAction.next,
                  controller: controller,
                  decoration: InputDecoration(
                    helperText: helperText,
                    filled: true,
                    fillColor: readOnly
                        ? AppTheme.bg
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        width: 0,
                        color: Colors.white,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: Colors.blue,
                      fontSize: textScaleFactor * 10.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
