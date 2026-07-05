import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/supplier_cubit.dart';
import '../cubit/supplier_state.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_form_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/supplier.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SupplierCubit>().loadSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSupplierForm([Supplier? supplier]) {
    showDialog(
      context: context,
      builder: (dialogContext) => SupplierFormDialog(
        supplier: supplier,
        onSave: (s) {
          if (supplier == null) {
            context.read<SupplierCubit>().addSupplier(s);
          } else {
            context.read<SupplierCubit>().updateSupplier(s);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: BlocBuilder<SupplierCubit, SupplierState>(
                  builder: (context, state) {
                    if (state is SupplierLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SupplierLoaded) {
                      if (state.suppliers.isEmpty) {
                        return _buildEmptyState();
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(32),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isWideScreen ? 550 : 800,
                          mainAxisExtent: 200,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: state.suppliers.length,
                        itemBuilder: (context, index) {
                          return SupplierCard(
                            supplier: state.suppliers[index],
                            margin: EdgeInsets.zero,
                            onTap: () => _showSupplierForm(state.suppliers[index]),
                          );
                        },
                      );
                    } else if (state is SupplierError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: () => _showSupplierForm(),
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: Text('Add Partner', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
        elevation: 8,
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
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                context.read<SupplierCubit>().searchSuppliers(query);
              },
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search partners by name or region...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.business_center_outlined,
      title: 'No suppliers registered',
      subtitle: 'Start building your supply network by adding a partner.',
    );
  }
}
