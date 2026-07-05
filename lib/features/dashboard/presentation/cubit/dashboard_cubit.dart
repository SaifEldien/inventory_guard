import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ProductRepository productRepository;
  final SupplierRepository supplierRepository;

  DashboardCubit({
    required this.productRepository,
    required this.supplierRepository,
  }) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    
    final productsResult = await productRepository.getAllProducts();
    final suppliersResult = await supplierRepository.getAllSuppliers();

    productsResult.fold(
      (failure) {
        debugPrint('DashboardCubit: Failed to load products: ${failure.message}');
        emit(DashboardError(failure.message));
      },
      (products) {
        suppliersResult.fold(
          (failure) {
            debugPrint('DashboardCubit: Failed to load suppliers: ${failure.message}');
            emit(DashboardError(failure.message));
          },
          (suppliers) {
            double totalValue = 0;
            int lowStockCount = 0;
            Map<String, int> distribution = {};

            for (var p in products) {
              totalValue += p.totalValue;
              if (p.isLowStock) lowStockCount++;
              distribution[p.category] = (distribution[p.category] ?? 0) + 1;
            }

            debugPrint('DashboardCubit: Successfully loaded data. Products: ${products.length}, Suppliers: ${suppliers.length}');
            emit(DashboardLoaded(
              totalValue: totalValue,
              lowStockCount: lowStockCount,
              totalProducts: products.length,
              totalSuppliers: suppliers.length,
              categoryDistribution: distribution,
            ));
          },
        );
      },
    );
  }
}
