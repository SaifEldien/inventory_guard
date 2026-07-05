import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/audit_log_model.dart';
import 'audit_remote_data_source.dart';

class AuditFirestoreDataSourceImpl implements AuditRemoteDataSource {
  final FirebaseFirestore firestore;

  AuditFirestoreDataSourceImpl({required this.firestore});

  CollectionReference get _logs => firestore.collection('audit_logs');

  @override
  Future<void> uploadLog(AuditLogModel log) async {
    await _logs.doc(log.id).set(log.toJson());
  }

  @override
  Future<List<AuditLogModel>> getAllLogs({int limit = 50, int offset = 0}) async {
    final snapshot = await _logs.orderBy('timestamp', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) => AuditLogModel.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    })).toList();
  }

  @override
  Future<List<AuditLogModel>> getLogsByProduct(String productId) async {
    final snapshot = await _logs.where('productId', isEqualTo: productId)
                               .orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => AuditLogModel.fromJson({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    })).toList();
  }
}
