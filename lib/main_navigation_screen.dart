import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/products/presentation/pages/product_list_screen.dart';
import 'features/suppliers/presentation/pages/supplier_list_screen.dart';
import 'features/audit/presentation/pages/audit_log_screen.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';
import 'features/warehouses/presentation/pages/warehouse_list_screen.dart';
import 'core/theme/app_colors.dart';
import 'injection_container.dart';
import 'features/products/presentation/cubit/product_cubit.dart';
import 'features/products/presentation/cubit/product_state.dart';
import 'features/suppliers/presentation/cubit/supplier_cubit.dart';
import 'features/audit/presentation/cubit/audit_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/warehouses/presentation/cubit/warehouse_cubit.dart';
import 'core/notifications/presentation/cubit/notification_cubit.dart';
import 'core/notifications/domain/entities/app_notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductListScreen(),
    const WarehouseListScreen(),
    const SupplierListScreen(),
    const AuditLogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardCubit>()),
        BlocProvider(create: (_) => sl<ProductCubit>()),
        BlocProvider(create: (_) => sl<SupplierCubit>()),
        BlocProvider(create: (_) => sl<AuditCubit>()),
        BlocProvider(create: (_) => sl<WarehouseCubit>()..loadWarehouses()),
        BlocProvider(create: (_) => sl<NotificationCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProductCubit, ProductState>(
            listener: (context, state) {
              if (state is ProductLoaded) {
                final lowStockProducts = state.products.where((p) => p.isLowStock).toList();
                for (final product in lowStockProducts) {
                  context.read<NotificationCubit>().addNotification(
                    AppNotification(
                      id: 'low-stock-${product.id}',
                      title: 'Low Stock Alert',
                      message: '${product.name} is running low (${product.quantity} left)',
                      type: NotificationType.lowStock,
                      timestamp: DateTime.now(),
                      productId: product.id,
                    ),
                  );
                }
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
          children: [
            if (isWideScreen) _buildSideNav(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(isWideScreen),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: isWideScreen ? null : _buildBottomNav(),
      ),
    ));
  }

  Widget _buildTopBar(bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          if (!isWide) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset('assets/logos/logo.png', height: 20, width: 20),
            ),
            const SizedBox(width: 12),
            Text( 
              'IG Digital', 
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, 
                fontSize: 18,
                color: AppColors.textPrimary,
              )
            ),
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPageTitle(),
                  style: GoogleFonts.outfit(
                    fontSize: 22, 
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Manage and monitor your digital assets',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
          _buildNotificationIcon(),
          const SizedBox(width: 16),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              String initials = '??';
              String? name;
              String? email;

              if (state is Authenticated) {
                name = state.user.name;
                email = state.user.email;
                if (name != null && name.isNotEmpty) {
                  initials = name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase();
                } else if (email.isNotEmpty) {
                  initials = email.substring(0, 1).toUpperCase();
                }
              }

              return PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthCubit>().logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name ?? 'User', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text(email ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                        const Divider(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                        const SizedBox(width: 12),
                        Text('Logout', style: GoogleFonts.plusJakartaSans(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                  backgroundImage: state is Authenticated && state.user.photoUrl != null 
                      ? NetworkImage(state.user.photoUrl!) 
                      : null,
                  child: state is Authenticated && state.user.photoUrl == null
                      ? Text(
                          initials,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (state.notifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        context.read<NotificationCubit>().markAllAsRead();
                        Navigator.pop(context);
                      },
                      child: Text('Mark all read', style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                    ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            if (state.notifications.isEmpty)
              PopupMenuItem(
                enabled: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded, color: AppColors.textTertiary, size: 32),
                        const SizedBox(height: 8),
                        Text('No notifications', style: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...state.notifications.take(5).map((n) => PopupMenuItem(
                onTap: () => context.read<NotificationCubit>().markAsRead(n.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: n.type == NotificationType.lowStock 
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          n.type == NotificationType.lowStock ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                          size: 14,
                          color: n.type == NotificationType.lowStock ? AppColors.error : AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              n.message,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, HH:mm').format(n.timestamp),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              )),
          ],
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
              ),
              if (state.hasUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard Overview';
      case 1: return 'Inventory Management';
      case 2: return 'Warehouse Network';
      case 3: return 'Supplier Network';
      case 4: return 'Activity Ledger';
      default: return 'IG Digital';
    }
  }

  Widget _buildSideNav() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset('assets/logos/logo.png', height: 28, width: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'INVENTORY',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'GUARD PRO',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.white54,
                          letterSpacing: 2.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(0, 'Dashboard', Icons.grid_view_outlined, Icons.grid_view_rounded),
                _buildNavItem(1, 'Inventory', Icons.inventory_2_outlined, Icons.inventory_2),
                _buildNavItem(2, 'Warehouses', Icons.warehouse_outlined, Icons.warehouse_rounded),
                _buildNavItem(3, 'Suppliers', Icons.business_outlined, Icons.business),
                _buildNavItem(4, 'Activity Logs', Icons.history_outlined, Icons.history),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'CONTACT ME',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Looking for a Expert?',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Let\'s build something amazing together.',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white60,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showDeveloperProfile(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Get in Touch', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, IconData activeIcon) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
              ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1)
              : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon, 
                color: isSelected ? Colors.white : Colors.white54, 
                size: 20
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.warehouse_outlined), activeIcon: Icon(Icons.warehouse_rounded), label: 'Warehouses'),
          BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business), label: 'Partners'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Logs'),
        ],
      ),
    );
  }

  void _showDeveloperProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          Color(0xFF1E293B),
                          Color(0xFF334155),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white10,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 85,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 54,
                          backgroundImage: AssetImage('assets/images/saif.jpg'),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    right: 145,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'Saifeldeen',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Available Worldwide',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Flutter Developer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Turning complex ideas into beautiful, high-performance digital realities. Expert in Flutter, Firebase & Scalable Architectures.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL('mailto:sief.ahmed98@yahoo.com'),
                            icon: const Icon(Icons.email_outlined, size: 18),
                            label: const Text('Contact Me'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: IconButton(
                            onPressed: () => _launchURL('https://saifeldeen-portfolio.vercel.app/'),
                            icon: const Icon(Icons.language_rounded, color: AppColors.textPrimary),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildSkillChip('Flutter'),
                        _buildSkillChip('Firebase'),
                        _buildSkillChip('Clean Architecture'),
                        _buildSkillChip('Dart'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMinimalSocialIcon(
                          Icons.link_rounded, 
                          'LinkedIn',
                          'https://www.linkedin.com/in/saif-ahmed-95a19a215/',
                        ),
                        _buildMinimalSocialIcon(
                          Icons.code_rounded, 
                          'GitHub',
                          'https://github.com/SaifEldien',
                        ),
                        _buildMinimalSocialIcon(
                          Icons.description_rounded, 
                          'Resume',
                          'https://drive.google.com/file/d/18CMUp-0ilVVTSOBXS2rQRwNaZlTIhi7T/view',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '© saifeldeen 2026',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMinimalSocialIcon(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    
    if (kIsWeb && url.startsWith('mailto:')) {
      html.window.location.href = url;
      return;
    }

    try {
      await launchUrl(
        uri, 
        mode: url.startsWith('mailto:') 
            ? LaunchMode.platformDefault 
            : LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}
