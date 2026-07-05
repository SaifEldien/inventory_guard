import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../../warehouses/presentation/cubit/warehouse_cubit.dart';
import '../../../warehouses/presentation/cubit/warehouse_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/import_export_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  void _showAddProductDialog() {
    final productCubit = context.read<ProductCubit>();
    final warehouseCubit = context.read<WarehouseCubit>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: productCubit,
        child: BlocProvider.value(
          value: warehouseCubit,
          child: ProductFormDialog(
            onSave: (product) {
              productCubit.addProduct(product);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide) _buildFilterSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isWide),
                Expanded(
                  child: BlocBuilder<WarehouseCubit, WarehouseState>(
                    builder: (context, warehouseState) {
                      final selectedWarehouseId = warehouseState is WarehouseLoaded 
                          ? warehouseState.selectedWarehouseId 
                          : null;

                      return BlocBuilder<ProductCubit, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is ProductLoaded) {
                            var filteredProducts = _selectedCategory == null
                                ? state.products
                                : state.products.where((p) => p.category == _selectedCategory).toList();

                            // Filter by warehouse
                            if (selectedWarehouseId != null) {
                              filteredProducts = filteredProducts
                                  .where((p) => p.warehouseId == selectedWarehouseId)
                                  .toList();
                            }

                            if (filteredProducts.isEmpty) {
                              return _buildEmptyState();
                            }
                            
                            return GridView.builder(
                              padding: const EdgeInsets.all(32),
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: isWide ? 400 : 600,
                                mainAxisExtent: 160,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final productCubit = context.read<ProductCubit>();
                                return ProductCard(
                                  product: filteredProducts[index],
                                  margin: EdgeInsets.zero,
                                  onTap: () {
                                    final warehouseCubit = context.read<WarehouseCubit>();
                                    showDialog(
                                      context: context,
                                      builder: (context) => BlocProvider.value(
                                        value: productCubit,
                                        child: BlocProvider.value(
                                          value: warehouseCubit,
                                          child: ProductFormDialog(
                                            product: filteredProducts[index],
                                            onSave: (product) {
                                              productCubit.updateProduct(product);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else if (state is ProductError) {
                            return _buildErrorState(state.message);
                          }
                          return const SizedBox();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Product', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
        elevation: 8,
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildSearchBar()),
          const SizedBox(width: 16),
          _buildActionIcon(
            Icons.file_upload_outlined, 
            () async {
              final maps = await ImportExportHelper.importProductsFromCsv();
              if (maps != null && mounted) {
                // Show a snackbar or progress dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Importing ${maps.length} products...'))
                );
                context.read<ProductCubit>().bulkImportProducts(maps);
              }
            }
          ),
          const SizedBox(width: 12),
          _buildActionIcon(
            Icons.file_download_outlined, 
            () {
              final state = context.read<ProductCubit>().state;
              if (state is ProductLoaded) {
                ImportExportHelper.exportProductsToCsv(state.products);
              }
            }
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildFilterSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              Text(
                'Filter Items',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildWarehouseFilter(),
          const SizedBox(height: 40),
          _buildFilterSection('Categories', [
            'All',
            'Electronics',
            'Furniture',
            'Office Supplies',
            'Hardware'
          ]),
          const SizedBox(height: 40),
          _buildFilterSection('Stock Levels', [
            'All Status',
            'In Stock',
            'Low Stock',
            'Out of Stock'
          ]),
        ],
      ),
    );
  }

  Widget _buildWarehouseFilter() {
    return BlocBuilder<WarehouseCubit, WarehouseState>(
      builder: (context, state) {
        if (state is WarehouseLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WAREHOUSE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ...[null, ...state.warehouses].map((wh) {
                final isSelected = state.selectedWarehouseId == wh?.id;
                final name = wh?.name ?? 'All Locations';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => context.read<WarehouseCubit>().selectWarehouse(wh?.id),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            wh == null ? Icons.all_inbox_rounded : Icons.warehouse_rounded,
                            size: 16,
                            color: isSelected ? AppColors.accent : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            name,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected ? AppColors.accent : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ...options.map((option) {
          final isSelected = (_selectedCategory == option) || (option == 'All' && _selectedCategory == null);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = option == 'All' ? null : option;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.cardBorder,
                          width: 1.5,
                        ),
                        color: isSelected ? AppColors.accent : Colors.transparent,
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      option,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14),
      onChanged: (query) {
        context.read<ProductCubit>().searchProducts(query);
      },
      decoration: InputDecoration(
        hintText: 'Search inventory...',
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProductCubit>().loadProducts(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'No products found',
      subtitle: 'Your inventory is currently empty.\nAdd your first product to get started.',
    );
  }
}
