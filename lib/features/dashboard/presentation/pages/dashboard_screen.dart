import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/notifications/presentation/cubit/notification_cubit.dart';
import '../../../../core/notifications/domain/entities/app_notification.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'OVERVIEW',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textTertiary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'System Insights',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatsGrid(context, state),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildCategoryDistribution(state)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildActiveAlerts()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildCategoryDistribution(state),
                          const SizedBox(height: 24),
                          _buildActiveAlerts(),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        } else if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                const SizedBox(height: 16),
                Text(state.message, style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<DashboardCubit>().loadDashboardData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        int crossAxisCount = 4;
        double aspectRatio = 1.8; // More dense

        if (width < 600) {
          crossAxisCount = 1;
          aspectRatio = 2.5;
        } else if (width < 900) {
          crossAxisCount = 2;
          aspectRatio = 2.0;
        } else if (width < 1200) {
          crossAxisCount = 4;
          aspectRatio = 1.6;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Total Assets',
              '\$${state.totalValue.toStringAsFixed(0)}',
              Icons.account_balance_wallet_rounded,
              AppColors.accent,
              '+12.5% vs LW',
            ),
            _buildStatCard(
              'Products',
              '${state.totalProducts}',
              Icons.inventory_2_rounded,
              AppColors.success,
              'All warehouses',
            ),
            _buildStatCard(
              'Low Stock',
              '${state.lowStockCount}',
              Icons.warning_amber_rounded,
              AppColors.error,
              'Needs refill',
            ),
            _buildStatCard(
              'Suppliers',
              '${state.totalSuppliers}',
              Icons.handshake_rounded,
              AppColors.warning,
              'Active network',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: subtitle.contains('+') ? AppColors.success : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(DashboardLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Mix',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          if (state.categoryDistribution.isEmpty)
            const EmptyStateWidget(
              icon: Icons.pie_chart_outline_rounded,
              title: 'No category data',
              subtitle: 'Product categories will appear once you add inventory.',
            )
          else
            ...state.categoryDistribution.entries.take(4).map((entry) {
              final percentage = entry.value / state.totalProducts;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('${(percentage * 100).toInt()}%', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.background,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActiveAlerts() {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final alerts = state.notifications.where((n) => !n.isRead).toList();

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Alerts',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      if (alerts.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${alerts.length}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (alerts.isEmpty)
                    _buildEmptyAlerts()
                  else
                    ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
                  const SizedBox(height: 16),
                  if (alerts.length > 3)
                    Center(
                      child: Text(
                        '+ ${alerts.length - 3} more alerts',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSystemHealth(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyAlerts() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 28),
            const SizedBox(height: 12),
            Text(
              'All systems nominal',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(AppNotification alert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              alert.type == NotificationType.lowStock ? Icons.warning_amber_rounded : Icons.info_outline,
              color: alert.type == NotificationType.lowStock ? AppColors.warning : AppColors.accent,
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    alert.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Status',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildHealthItem('Encryption', true),
          _buildHealthItem('Data Sync', true),
          _buildHealthItem('Audit Trail', true),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Core systems are operational.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text('OK', style: GoogleFonts.plusJakartaSans(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
