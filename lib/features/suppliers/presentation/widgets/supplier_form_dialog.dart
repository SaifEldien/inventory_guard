import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/supplier.dart';
import '../../../../core/theme/app_colors.dart';

class SupplierFormDialog extends StatefulWidget {
  final Supplier? supplier;
  final Function(Supplier) onSave;

  const SupplierFormDialog({
    super.key,
    this.supplier,
    required this.onSave,
  });

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _categoriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _contactPersonController = TextEditingController(text: widget.supplier?.contactPerson ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _categoriesController = TextEditingController(
      text: widget.supplier?.suppliedCategories.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _categoriesController.dispose();
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
        child: SingleChildScrollView(
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
                        widget.supplier == null ? Icons.business_rounded : Icons.edit_note_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      widget.supplier == null ? 'New Supplier' : 'Edit Supplier',
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
                      _buildLabel('General Information'),
                      const SizedBox(height: 16),
                      _buildTextField(_nameController, 'Company Name', 'e.g. Acme Corp', Icons.business_outlined),
                      const SizedBox(height: 24),
                      _buildTextField(_contactPersonController, 'Primary Contact', 'Name of person', Icons.person_outline),
                      const SizedBox(height: 32),
                      _buildLabel('Contact Channels'),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildTextField(_emailController, 'Email Address', 'contact@company.com', Icons.email_outlined)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildTextField(_phoneController, 'Phone Number', '+1 234...', Icons.phone_outlined)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        _categoriesController,
                        'Product Categories',
                        'e.g. Electronics, Hardware (comma separated)',
                        Icons.category_outlined,
                      ),
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
                        minimumSize: const Size(160, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.supplier == null ? 'Add Supplier' : 'Save Changes',
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon) {
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
            if (label.contains('Email') && !value.contains('@')) return 'Invalid email';
            return null;
          },
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final categories = _categoriesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final supplier = Supplier(
        id: widget.supplier?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        suppliedCategories: categories,
      );
      widget.onSave(supplier);
      Navigator.pop(context);
    }
  }
}
