import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/supplier.dart';
import '../cubit/supplier_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
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
                    alignment: Alignment.center,
                    child: Text(
                      supplier.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
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
                          supplier.contactPerson,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPartnerTag(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContactInfo(Icons.alternate_email_rounded, supplier.email),
                        const SizedBox(height: 4),
                        _buildContactInfo(Icons.phone_iphone_rounded, supplier.phone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickActions(context),
                ],
              ),
              if (supplier.suppliedCategories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: supplier.suppliedCategories
                      .take(3)
                      .map((cat) => _buildCategoryTag(cat))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'PARTNER',
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTag(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Text(
        category,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Supplier', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18)
        ),
        content: Text(
          'Dissolve partnership with ${supplier.name}?',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SupplierCubit>().deleteSupplier(supplier.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
