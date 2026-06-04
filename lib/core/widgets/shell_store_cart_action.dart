import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_bloc.dart';
import 'package:recycleorigin/features/store_feature/presentation/bloc/products_state.dart';
import 'package:recycleorigin/features/store_feature/presentation/screens/cart_screen.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Cart affordance for the store tab in the bottom-navigation shell.
class ShellStoreCartAction extends StatelessWidget {
  const ShellStoreCartAction({super.key});

  @override
  Widget build(BuildContext context) {
    final onAppBar = Theme.of(context).appBarTheme.foregroundColor ??
        context.appColors.onHeroForeground;

    return BlocBuilder<ProductsBloc, ProductsState>(
      buildWhen: (a, b) => a.cartItems.length != b.cartItems.length,
      builder: (context, state) {
        final count = state.cartItems.length;
        final cartIcon = IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(CartScreen.routeName);
          },
          icon: Icon(Icons.shopping_cart_outlined, color: onAppBar),
          tooltip: context.l10n.shoppingCartLabel,
        );
        if (count == 0) return cartIcon;
        return badges.Badge(
          badgeContent: Text(
            count.toString(),
            style: TextStyle(
              color: context.appColors.onHeroForeground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: AppTheme.accent,
            padding: const EdgeInsets.all(6),
          ),
          child: cartIcon,
        );
      },
    );
  }
}
