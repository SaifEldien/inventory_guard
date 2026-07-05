import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'supplier_state.dart';
import '../../domain/usecases/get_all_suppliers.dart';
import '../../domain/usecases/add_supplier.dart';
import '../../domain/usecases/update_supplier.dart';
import '../../domain/usecases/delete_supplier.dart';
import '../../domain/entities/supplier.dart';
import '../../../../core/error/failures.dart';

class SupplierCubit extends Cubit<SupplierState> {
  final GetAllSuppliers getAllSuppliers;
  final AddSupplier addSupplierUseCase;
  final UpdateSupplier updateSupplierUseCase;
  final DeleteSupplier deleteSupplierUseCase;

  SupplierCubit({
    required this.getAllSuppliers,
    required this.addSupplierUseCase,
    required this.updateSupplierUseCase,
    required this.deleteSupplierUseCase,
  }) : super(SupplierInitial());

  Future<void> loadSuppliers({String? query}) async {
    debugPrint('SupplierCubit: Loading suppliers... query: $query');
    emit(SupplierLoading());
    final result = await getAllSuppliers(GetAllSuppliersParams(query: query));
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('SupplierCubit: Load failed: $message');
        emit(SupplierError(message));
      },
      (suppliers) {
        debugPrint('SupplierCubit: Loaded ${suppliers.length} suppliers');
        emit(SupplierLoaded(suppliers));
      },
    );
  }

  Future<void> searchSuppliers(String query) async {
    debugPrint('SupplierCubit: Searching suppliers... query: $query');
    final result = await getAllSuppliers(GetAllSuppliersParams(query: query));
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('SupplierCubit: Search failed: $message');
        emit(SupplierError(message));
      },
      (suppliers) => emit(SupplierLoaded(suppliers)),
    );
  }

  Future<void> addSupplier(Supplier supplier) async {
    debugPrint('SupplierCubit: Adding supplier: ${supplier.name}');
    final result = await addSupplierUseCase(supplier);
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('SupplierCubit: Add failed: $message');
        emit(SupplierError(message));
      },
      (_) => loadSuppliers(),
    );
  }

  Future<void> updateSupplier(Supplier supplier) async {
    debugPrint('SupplierCubit: Updating supplier: ${supplier.id}');
    final result = await updateSupplierUseCase(supplier);
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('SupplierCubit: Update failed: $message');
        emit(SupplierError(message));
      },
      (_) => loadSuppliers(),
    );
  }

  Future<void> deleteSupplier(String id) async {
    debugPrint('SupplierCubit: Deleting supplier: $id');
    final result = await deleteSupplierUseCase(id);
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        debugPrint('SupplierCubit: Delete failed: $message');
        emit(SupplierError(message));
      },
      (_) => loadSuppliers(),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    return "An unexpected error occurred.";
  }
}
