import 'package:equatable/equatable.dart';
import '../../domain/entities/warehouse.dart';

abstract class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<Warehouse> warehouses;
  final String? selectedWarehouseId;

  const WarehouseLoaded(this.warehouses, {this.selectedWarehouseId});

  @override
  List<Object?> get props => [warehouses, selectedWarehouseId];
}

class WarehouseError extends WarehouseState {
  final String message;

  const WarehouseError(this.message);

  @override
  List<Object?> get props => [message];
}
