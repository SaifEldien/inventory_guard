import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double totalValue;
  final int lowStockCount;
  final int totalProducts;
  final int totalSuppliers;
  final Map<String, int> categoryDistribution;

  const DashboardLoaded({
    required this.totalValue,
    required this.lowStockCount,
    required this.totalProducts,
    required this.totalSuppliers,
    required this.categoryDistribution,
  });

  @override
  List<Object?> get props => [totalValue, lowStockCount, totalProducts, totalSuppliers, categoryDistribution];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
