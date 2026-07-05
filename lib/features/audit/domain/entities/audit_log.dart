import 'package:equatable/equatable.dart';
import '../enums/action_type.dart';

class AuditLog extends Equatable {
  final String id;
  final String productId;
  final ActionType actionType;
  final int quantityChanged;
  final DateTime timestamp;
  final String userId;
  final String? notes;

  const AuditLog({
    required this.id,
    required this.productId,
    required this.actionType,
    required this.quantityChanged,
    required this.timestamp,
    required this.userId,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        actionType,
        quantityChanged,
        timestamp,
        userId,
        notes,
      ];

  AuditLog copyWith({
    String? id,
    String? productId,
    ActionType? actionType,
    int? quantityChanged,
    DateTime? timestamp,
    String? userId,
    String? notes,
  }) {
    return AuditLog(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      actionType: actionType ?? this.actionType,
      quantityChanged: quantityChanged ?? this.quantityChanged,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
    );
  }
}
