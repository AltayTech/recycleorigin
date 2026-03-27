import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth_feature/presentation/bloc/auth_bloc.dart';
import '../../business/entities/address.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressItem extends StatefulWidget {
  final Address addressItem;
  final bool isSelected;
  final VoidCallback? onTap;

  const AddressItem({
    Key? key,
    required this.addressItem,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  _AddressItemState createState() => _AddressItemState();
}

class _AddressItemState extends State<AddressItem> {
  bool _isLoading = false;

  Future<void> _removeItem() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthBloc>();

      await authProvider.getAddresses();
      final List<Address> currentList = authProvider.addressItems;

      currentList.removeWhere((item) => item.name == widget.addressItem.name);

      await authProvider.updateAddress(currentList);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing address: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: AppTheme.primary, width: 1)
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.addressItem.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.h1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.addressItem.region.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.addressItem.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.grey.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30), // Space for delete button
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: _isLoading ? null : _removeItem,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          )
                        : Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey[400],
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
