import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.category,
    required super.quantity,
    required super.unitPrice,
    required super.supplierId,
    required super.warehouseId,
    required super.lowStockThreshold,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      supplierId: json['supplierId'] as String,
      warehouseId: json['warehouseId'] as String? ?? 'default',
      lowStockThreshold: json['lowStockThreshold'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'supplierId': supplierId,
      'warehouseId': warehouseId,
      'lowStockThreshold': lowStockThreshold,
    };
  }
}

extension ProductModelX on ProductModel {
  Product toEntity() => Product(
        id: id,
        name: name,
        sku: sku,
        category: category,
        quantity: quantity,
        unitPrice: unitPrice,
        supplierId: supplierId,
        warehouseId: warehouseId,
        lowStockThreshold: lowStockThreshold,
      );
}

extension ProductX on Product {
  ProductModel toModel() => ProductModel(
        id: id,
        name: name,
        sku: sku,
        category: category,
        quantity: quantity,
        unitPrice: unitPrice,
        supplierId: supplierId,
        warehouseId: warehouseId,
        lowStockThreshold: lowStockThreshold,
      );
}
