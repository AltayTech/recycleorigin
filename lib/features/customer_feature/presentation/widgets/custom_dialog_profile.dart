import 'package:flutter/material.dart';
import '../../../../core/theme/theme_context_extensions.dart';

import '../../../../core/theme/app_theme.dart';
import '../screens/profile_screen.dart';

/// Prompts the user to complete their profile before continuing.
class CustomDialogProfile extends StatelessWidget {
  const CustomDialogProfile({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.image,
  });

  final String title;
  final String description;
  final String buttonText;
  final Image image;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_DialogConsts.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _DialogBody(
        title: title,
        description: description,
        buttonText: buttonText,
        image: image,
      ),
    );
  }
}

class _DialogBody extends StatelessWidget {
  const _DialogBody({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.image,
  });

  final String title;
  final String description;
  final String buttonText;
  final Image image;

  @override
  Widget build(BuildContext context) {
    final titleSize = MediaQuery.textScalerOf(context).scale(16);
    final bodySize = MediaQuery.textScalerOf(context).scale(14);
    final buttonSize = MediaQuery.textScalerOf(context).scale(16);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: _DialogConsts.avatarRadius),
          padding: const EdgeInsets.only(
            top: _DialogConsts.avatarRadius + _DialogConsts.padding,
            bottom: _DialogConsts.padding,
            left: _DialogConsts.padding,
            right: _DialogConsts.padding,
          ),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(_DialogConsts.padding),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.26),
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.appColors.info,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appColors.subtitleColor,
                  fontSize: bodySize,
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Material(
                  color: AppTheme.primary,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .popAndPushNamed(ProfileScreen.routeName);
                    },
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.06,
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      child: Center(
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: context.appColors.onHeroForeground,
                            fontSize: buttonSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: CircleAvatar(
            radius: _DialogConsts.avatarRadius + 8,
            backgroundColor: context.appColors.cardBackground,
            child: ClipOval(child: image),
          ),
        ),
      ],
    );
  }
}

class _DialogConsts {
  _DialogConsts._();

  static const double padding = 16;
  static const double avatarRadius = 36;
}
