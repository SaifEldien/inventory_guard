import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/audit_cubit.dart';
import '../cubit/audit_state.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/enums/action_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _selectedFilter = 'All Actions';

  @override
  void initState() {
    super.initState();
    // Using watchLogs to enable real-time updates via streams
    context.read<AuditCubit>().watchLogs();
  }

  List<AuditLog> _getFilteredLogs(List<AuditLog> logs) {
    if (_selectedFilter == 'All Actions') return logs;
    
    return logs.where((log) {
      if (_selectedFilter == 'Stock Changes') {
        return log.actionType == ActionType.stockIn || log.actionType == ActionType.stockOut;
      }
      if (_selectedFilter == 'Product Edits') {
        return log.actionType == ActionType.create || 
               log.actionType == ActionType.update || 
               log.actionType == ActionType.delete;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: BlocBuilder<AuditCubit, AuditState>(
                  builder: (context, state) {
                    if (state is AuditLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AuditLoaded) {
                      final filteredLogs = _getFilteredLogs(state.logs);
                      
                      if (filteredLogs.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      return ListView.separated(
                        padding: const EdgeInsets.all(32),
                        itemCount: filteredLogs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildLogItem(filteredLogs[index]);
                        },
                      );
                    } else if (state is AuditError) {
                      return Center(child: Text(state.message, style: GoogleFonts.plusJakartaSans(color: AppColors.error)));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            'Activity History',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const Spacer(),
          _buildFilterChip('All Actions'),
          const SizedBox(width: 12),
          _buildFilterChip('Stock Changes'),
          const SizedBox(width: 12),
          _buildFilterChip('Product Edits'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(AuditLog log) {
    final bool isPositive = log.quantityChanged > 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getActionColor(log.actionType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getActionIcon(log.actionType),
              color: _getActionColor(log.actionType),
              size: 22,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getActionTitle(log),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.textTertiary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Item ID: ${log.productId.length > 8 ? log.productId.substring(0, 8) : log.productId}... by ${log.userId.split('@').first}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (log.quantityChanged != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${log.quantityChanged}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontSize: 16,
                ),
              ),
            ),
          const SizedBox(width: 16),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.history_toggle_off_rounded,
      title: 'Activity Ledger Empty',
      subtitle: 'Transactions and system changes will appear here.',
    );
  }

  Color _getActionColor(ActionType type) {
    switch (type) {
      case ActionType.create: return AppColors.accent;
      case ActionType.update: return AppColors.warning;
      case ActionType.delete: return AppColors.error;
      case ActionType.stockIn: return AppColors.success;
      case ActionType.stockOut: return AppColors.error;
    }
  }

  IconData _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.create: return Icons.add_circle_outline;
      case ActionType.update: return Icons.edit_outlined;
      case ActionType.delete: return Icons.delete_outline;
      case ActionType.stockIn: return Icons.arrow_downward;
      case ActionType.stockOut: return Icons.arrow_upward;
    }
  }

  String _getActionTitle(AuditLog log) {
    switch (log.actionType) {
      case ActionType.create: return 'Product Added';
      case ActionType.update: return 'Details Updated';
      case ActionType.delete: return 'Product Removed';
      case ActionType.stockIn: return 'Stock In';
      case ActionType.stockOut: return 'Stock Out';
    }
  }
}
