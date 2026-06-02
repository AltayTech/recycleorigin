import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/l10n/l10n.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../business/entities/address.dart';

/// Selectable address card with radio indicator, region badge,
/// swipe-to-delete support, and animated selection state.
class AddressItem extends StatefulWidget {
  final Address addressItem;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemoved;

  const AddressItem({
    super.key,
    required this.addressItem,
    this.isSelected = false,
    this.onTap,
    this.onRemoved,
  });

  @override
  State<AddressItem> createState() => _AddressItemState();
}

class _AddressItemState extends State<AddressItem>
    with SingleTickerProviderStateMixin {
  bool _isRemoving = false;

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: Colors.red.shade400,
            size: 28,
          ),
        ),
        title: Text(
          ctx.l10n.removeAddressTitle,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          ctx.l10n.removeAddressConfirmation,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Text(ctx.l10n.cancelLabel),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Text(ctx.l10n.removeLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _removeItem() async {
    final confirmed = await _confirmDelete();
    if (!confirmed) return;

    setState(() => _isRemoving = true);
    HapticFeedback.mediumImpact();

    try {
      final authProvider = context.read<AuthBloc>();
      await authProvider.getAddresses();
      final currentList = List<Address>.from(authProvider.addressItems);
      currentList.removeWhere((a) => a.name == widget.addressItem.name);
      await authProvider.updateAddress(currentList);
      widget.onRemoved?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.errorRemovingAddressPrefix}$e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRemoving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dismissible(
      key: ValueKey(widget.addressItem.name),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) => _removeItem(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppTheme.primary.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isSelected ? AppTheme.primary : Colors.grey.shade200,
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (widget.isSelected)
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap?.call();
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RadioIndicator(isSelected: widget.isSelected),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.addressItem.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: widget.isSelected
                                      ? AppTheme.primary
                                      : context.colors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isSelected)
                              _SelectionPill(label: l10n.selectedLabel),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _RegionBadge(
                          name: widget.addressItem.region.name,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.addressItem.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (_hasCoordinates) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.gps_fixed_rounded,
                                size: 12,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formattedCoords,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  _isRemoving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: _removeItem,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          tooltip: l10n.removeLabel,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasCoordinates =>
      widget.addressItem.latitude != '0.0' &&
      widget.addressItem.longitude != '0.0';

  String get _formattedCoords {
    final lat = double.tryParse(widget.addressItem.latitude) ?? 0;
    final lng = double.tryParse(widget.addressItem.longitude) ?? 0;
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }
}

/// Animated radio-style selection indicator.
class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppTheme.primary.withOpacity(0.12)
            : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppTheme.primary : Colors.grey.shade300,
          width: isSelected ? 6 : 2,
        ),
      ),
    );
  }
}

/// Small pill showing "Selected" on active card.
class _SelectionPill extends StatelessWidget {
  const _SelectionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Region label badge.
class _RegionBadge extends StatelessWidget {
  const _RegionBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map_rounded,
            size: 12,
            color: AppTheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
