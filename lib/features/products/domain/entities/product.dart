import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int quantity;
  final double unitPrice;
  final String supplierId;
  final String warehouseId;
  final int lowStockThreshold;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.supplierId,
    required this.warehouseId,
    required this.lowStockThreshold,
  });

  // Rich Domain Logic: المنطق أصبح داخل الـ Entity وليس مشتتاً في الـ UI
  bool get isLowStock => quantity <= lowStockThreshold;
  double get totalValue => quantity * unitPrice;

  // التحقق من صحة البيانات داخل الـ Entity
  bool get isValid => name.isNotEmpty && quantity >= 0 && unitPrice >= 0;

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        category,
        quantity,
        unitPrice,
        supplierId,
        warehouseId,
        lowStockThreshold,
      ];

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    int? quantity,
    double? unitPrice,
    String? supplierId,
    String? warehouseId,
    int? lowStockThreshold,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      supplierId: supplierId ?? this.supplierId,
      warehouseId: warehouseId ?? this.warehouseId,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}
