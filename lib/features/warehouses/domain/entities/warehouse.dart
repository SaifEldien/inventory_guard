import 'package:equatable/equatable.dart';

class Warehouse extends Equatable {
  final String id;
  final String name;
  final String location;
  final double? latitude;
  final double? longitude;
  final String description;
  final bool isActive;

  const Warehouse({
    required this.id,
    required this.name,
    required this.location,
    this.latitude,
    this.longitude,
    this.description = '',
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, location, latitude, longitude, description, isActive];

  Warehouse copyWith({
    String? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    String? description,
    bool? isActive,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
