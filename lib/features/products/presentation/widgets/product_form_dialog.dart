import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/warehouses/presentation/cubit/warehouse_cubit.dart';
import '../../../../features/warehouses/presentation/cubit/warehouse_state.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  String? _selectedCategory;
  String? _selectedWarehouse;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _thresholdController;

  final List<String> _categories = [
    'Electronics',
    'Furniture',
    'Office Supplies',
    'Hardware',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _selectedCategory = widget.product?.category;
    _selectedWarehouse = widget.product?.warehouseId ?? 'wh-main';
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
    }
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '0');
    _priceController = TextEditingController(text: widget.product?.unitPrice.toString() ?? '0.0');
    _thresholdController = TextEditingController(text: widget.product?.lowStockThreshold.toString() ?? '5');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, minWidth: 320),
        child: SingleChildScrollView( // Changed to SingleChildScrollView at the top level for safety
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.product == null ? Icons.add_box_rounded : Icons.edit_document,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      widget.product == null ? 'New Product' : 'Edit Product',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Product Details'),
                      const SizedBox(height: 16),
                      _buildTextField(_nameController, 'Product Name', 'e.g. MacBook Pro M3', Icons.inventory_2_outlined),
                      const SizedBox(height: 24),
                      _buildTextField(_skuController, 'SKU Code', 'IG-XXXXX', Icons.qr_code_rounded),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCategoryDropdown()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildWarehouseDropdown()),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildLabel('Inventory & Pricing'),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildTextField(_quantityController, 'Stock Quantity', '0', Icons.numbers_rounded, isNumber: true)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildTextField(_priceController, 'Unit Price (\$)', '0.00', Icons.attach_money_rounded, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(_thresholdController, 'Low Stock Alert Threshold', '5', Icons.notification_important_rounded, isNumber: true),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: Text('Discard', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(160, 52), // Fixed size for buttons is often better
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.product == null ? 'Create Product' : 'Save Changes',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textTertiary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 18),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (isNumber && double.tryParse(value) == null) return 'Invalid number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          dropdownColor: Colors.white,
          style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category_outlined, color: AppColors.textTertiary, size: 18),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          validator: (value) => value == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<WarehouseCubit, WarehouseState>(
      builder: (context, state) {
        List<DropdownMenuItem<String>> items = [];
        
        if (state is WarehouseLoaded) {
          items = state.warehouses.map((wh) {
            return DropdownMenuItem<String>(
              value: wh.id,
              child: Text(wh.name),
            );
          }).toList();
          if (items.isNotEmpty && !items.any((item) => item.value == _selectedWarehouse)) {
            _selectedWarehouse = items.first.value;
          }
        } else {
          // Fallback to avoid empty dropdown while loading
          items = [
            DropdownMenuItem(
              value: _selectedWarehouse ?? 'wh-main',
              child: Text(widget.product?.warehouseId != null ? 'Loading...' : 'Main Warehouse'),
            ),
          ];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warehouse',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedWarehouse,
              dropdownColor: Colors.white,
              style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.warehouse_outlined, color: AppColors.textTertiary, size: 18),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: items,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWarehouse = newValue;
                });
              },
              validator: (value) => value == null ? 'Required' : null,
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        category: _selectedCategory ?? 'Other',
        quantity: int.tryParse(_quantityController.text) ?? 0,
        unitPrice: double.tryParse(_priceController.text) ?? 0.0,
        supplierId: widget.product?.supplierId ?? '',
        warehouseId: _selectedWarehouse ?? 'wh-main',
        lowStockThreshold: int.tryParse(_thresholdController.text) ?? 5,
      );
      widget.onSave(product);
      Navigator.pop(context);
    }
  }
}
