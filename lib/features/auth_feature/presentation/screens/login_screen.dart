import 'package:flutter/material.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/widgets/main_drawer.dart';
import 'package:recycleorigin/features/auth_feature/presentation/screens/auth_card.dart';
import 'package:recycleorigin/l10n/l10n.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: Theme(
        data: theme.copyWith(canvasColor: Colors.transparent),
        child: const MainDrawer(),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.28),
                Colors.black.withValues(alpha: 0.62),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: AppTheme.spacingMd,
                        right: AppTheme.spacingMd,
                        top: AppTheme.spacingLg,
                        bottom: AppTheme.spacingLg + bottomInset,
                      ),
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - bottomInset,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.recycleorigin,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontFamily: 'BFarnaz',
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 14,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingXl),
                            Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 420),
                                child: const AuthCard(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Material(
                    type: MaterialType.transparency,
                    child: IconButton(
                      tooltip: l10n.authOpenMenuTooltip,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
