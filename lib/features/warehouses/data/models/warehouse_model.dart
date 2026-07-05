import '../../domain/entities/warehouse.dart';

class WarehouseModel extends Warehouse {
  const WarehouseModel({
    required super.id,
    required super.name,
    required super.location,
    super.latitude,
    super.longitude,
    super.description,
    super.isActive,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'isActive': isActive,
    };
  }

  factory WarehouseModel.fromEntity(Warehouse warehouse) {
    return WarehouseModel(
      id: warehouse.id,
      name: warehouse.name,
      location: warehouse.location,
      latitude: warehouse.latitude,
      longitude: warehouse.longitude,
      description: warehouse.description,
      isActive: warehouse.isActive,
    );
  }
}
