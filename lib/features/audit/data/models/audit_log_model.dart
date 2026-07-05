import '../../domain/entities/audit_log.dart';
import '../../domain/enums/action_type.dart';

class AuditLogModel extends AuditLog {
  const AuditLogModel({
    required super.id,
    required super.productId,
    required super.actionType,
    required super.quantityChanged,
    required super.timestamp,
    required super.userId,
    super.notes,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp vs int milliseconds
    DateTime parsedTimestamp;
    final dynamic ts = json['timestamp'];
    if (ts is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts != null && ts.runtimeType.toString() == 'Timestamp') {
      // Avoid direct dependency on cloud_firestore if possible in model
      // but if we are in data layer it's okay, or use a generic approach:
      parsedTimestamp = (ts as dynamic).toDate();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return AuditLogModel(
      id: (json['id'] ?? '') as String,
      productId: (json['productId'] ?? '') as String,
      actionType: ActionType.values.byName(json['actionType'] as String? ?? 'update'),
      quantityChanged: (json['quantityChanged'] ?? 0) as int,
      timestamp: parsedTimestamp,
      userId: (json['userId'] ?? '') as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'actionType': actionType.name,
      'quantityChanged': quantityChanged,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userId': userId,
      'notes': notes,
    };
  }

  factory AuditLogModel.fromEntity(AuditLog entity) {
    return AuditLogModel(
      id: entity.id,
      productId: entity.productId,
      actionType: entity.actionType,
      quantityChanged: entity.quantityChanged,
      timestamp: entity.timestamp,
      userId: entity.userId,
      notes: entity.notes,
    );
  }

  AuditLog toEntity() => AuditLog(
        id: id,
        productId: productId,
        actionType: actionType,
        quantityChanged: quantityChanged,
        timestamp: timestamp,
        userId: userId,
        notes: notes,
      );
}
