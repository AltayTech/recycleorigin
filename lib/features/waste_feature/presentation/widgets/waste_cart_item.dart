import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/wasteCart.dart';

import '../../../../core/logic/en_to_ar_number_convertor.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../bloc/wastes_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// A modern cart-item card with image, pricing, and a
/// quantity stepper. Supports swipe-to-dismiss.
class WasteCartItem extends StatefulWidget {
  final WasteCart wasteItem;
  final VoidCallback function;

  const WasteCartItem({
    super.key,
    required this.wasteItem,
    required this.function,
  });

  @override
  State<WasteCartItem> createState() => _WasteCartItemState();
}

class _WasteCartItemState extends State<WasteCartItem> {
  bool _isRemoving = false;

  String _getPrice(List<PriceWeight> prices, int weight) {
    for (var p in prices) {
      final tierWeight = int.tryParse(p.weight) ?? 0;
      if (weight > tierWeight) {
        return p.price;
      } else {
        return p.price;
      }
    }
    return '0';
  }

  int get _unitPrice =>
      int.tryParse(_getPrice(
        widget.wasteItem.prices,
        widget.wasteItem.weight,
      )) ??
      0;

  int get _totalPrice => _unitPrice * widget.wasteItem.weight;

  Future<void> _removeItem() async {
    setState(() => _isRemoving = true);
    await context.read<WastesBloc>().removeWasteCart(widget.wasteItem.id);
    widget.function();
  }

  Future<bool> _confirmDismiss() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(ctx.l10n.removeItemTitle),
        content: Text(ctx.l10n.removeItemConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(ctx.l10n.removeLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _updateWeight(int delta) {
    final newWeight = widget.wasteItem.weight + delta;
    if (newWeight < 1) return;

    HapticFeedback.lightImpact();
    context.read<WastesBloc>().updateWasteCart(
          widget.wasteItem,
          newWeight,
        );
    widget.function();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = intl.NumberFormat.decimalPattern();
    final converter = EnArConvertor();

    return Dismissible(
      key: ValueKey(widget.wasteItem.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDismiss(),
      onDismissed: (_) => _removeItem(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: AnimatedOpacity(
        opacity: _isRemoving ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _ItemImage(
                  imageUrl:
                      widget.wasteItem.featured_image.sizes.medium,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.wasteItem.name,
                        style: TextStyle(
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _PriceLabel(
                            label: l10n.perKiloLabel,
                            value: converter.replaceArNumber(
                              fmt.format(_unitPrice),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$',
                            style: TextStyle(
                              color: context.appColors.subtitleColor.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            l10n.totalLabel,
                            style: TextStyle(
                              color: context.appColors.subtitleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            converter.replaceArNumber(
                              fmt.format(_totalPrice),
                            ),
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '\$',
                            style: TextStyle(
                              color: AppTheme.primary.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _QuantityStepper(
                  quantity: widget.wasteItem.weight,
                  onIncrement: () => _updateWeight(1),
                  onDecrement: () => _updateWeight(-1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: context.appColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: FadeInImage(
        placeholder:
            const AssetImage('assets/images/main_page_request_ic.png'),
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
        imageErrorBuilder: (_, __, ___) => Icon(
          Icons.recycling_rounded,
          size: 32,
          color: AppTheme.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.appColors.subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: context.colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              EnArConvertor()
                  .replaceArNumber(quantity.toString()),
              style: TextStyle(
                color: context.colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            isDecrease: true,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.isDecrease = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDecrease;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDecrease
          ? Colors.red.shade50
          : AppTheme.primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: isDecrease ? Colors.red.shade400 : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
