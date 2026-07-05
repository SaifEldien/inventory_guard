import 'package:flutter_bloc/flutter_bloc.dart';
import 'warehouse_state.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/usecases/get_warehouses.dart';
import '../../domain/usecases/add_warehouse.dart';
import '../../domain/usecases/update_warehouse.dart';
import '../../domain/usecases/delete_warehouse.dart';
import '../../../../core/usecases/usecase.dart';

class WarehouseCubit extends Cubit<WarehouseState> {
  final GetWarehouses getWarehousesUseCase;
  final AddWarehouseUseCase addWarehouseUseCase;
  final UpdateWarehouseUseCase updateWarehouseUseCase;
  final DeleteWarehouseUseCase deleteWarehouseUseCase;

  WarehouseCubit({
    required this.getWarehousesUseCase,
    required this.addWarehouseUseCase,
    required this.updateWarehouseUseCase,
    required this.deleteWarehouseUseCase,
  }) : super(WarehouseInitial());

  Future<void> loadWarehouses() async {
    emit(WarehouseLoading());
    final result = await getWarehousesUseCase(NoParams());
    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (warehouses) => emit(WarehouseLoaded(warehouses)),
    );
  }

  void selectWarehouse(String? id) {
    if (state is WarehouseLoaded) {
      final currentState = state as WarehouseLoaded;
      emit(WarehouseLoaded(currentState.warehouses, selectedWarehouseId: id));
    }
  }

  Future<void> addWarehouse(Warehouse warehouse) async {
    final result = await addWarehouseUseCase(warehouse);
    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (_) => loadWarehouses(),
    );
  }

  Future<void> updateWarehouse(Warehouse warehouse) async {
    final result = await updateWarehouseUseCase(warehouse);
    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (_) => loadWarehouses(),
    );
  }

  Future<void> deleteWarehouse(String id) async {
    final result = await deleteWarehouseUseCase(id);
    result.fold(
      (failure) => emit(WarehouseError(failure.message)),
      (_) => loadWarehouses(),
    );
  }
}
