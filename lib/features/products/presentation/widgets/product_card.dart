import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.isLowStock;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowStock ? AppColors.error.withValues(alpha: 0.2) : AppColors.cardBorder, 
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.accent.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(product.category), 
                      color: AppColors.textSecondary, 
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          product.sku,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.warehouse_rounded, size: 10, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              product.warehouseId.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textTertiary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildPriceTag(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stock Level',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${product.quantity} Units',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isLowStock ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildStockIndicator(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickActions(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$${product.unitPrice.toStringAsFixed(2)}',
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildStockIndicator() {
    // Assuming a max reference for the bar, e.g., 100 or relative to product.minStock if it existed
    // For now, let's use a simple representation.
    final double percentage = (product.quantity / 50).clamp(0.0, 1.0); 
    final Color color = product.isLowStock ? AppColors.error : AppColors.success;

    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSmallAction(
          Icons.edit_rounded, 
          AppColors.textTertiary, 
          () => onTap?.call(),
        ),
        const SizedBox(width: 8),
        _buildSmallAction(
          Icons.delete_outline_rounded, 
          AppColors.error.withValues(alpha: 0.7), 
          () => _confirmDelete(context),
        ),
      ],
    );
  }

  Widget _buildSmallAction(IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('electronic')) return Icons.devices_rounded;
    if (cat.contains('food')) return Icons.restaurant_rounded;
    if (cat.contains('clothing')) return Icons.checkroom_rounded;
    if (cat.contains('furniture')) return Icons.chair_rounded;
    return Icons.inventory_2_outlined;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Deletion', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18)
        ),
        content: Text(
          'Are you sure you want to remove ${product.name}?',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProductCubit>().deleteProduct(product.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
