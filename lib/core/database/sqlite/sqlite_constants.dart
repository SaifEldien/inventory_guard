class SqliteConstants {
  // Table Names
  static const String tableProducts = 'products';
  static const String tableSuppliers = 'suppliers';
  static const String tableAuditLogs = 'audit_logs';

  // Product Columns
  static const String colProductId = 'id';
  static const String colProductName = 'name';
  static const String colProductSku = 'sku';
  static const String colProductCategory = 'category';
  static const String colProductQuantity = 'quantity';
  static const String colProductUnitPrice = 'unitPrice';
  static const String colProductSupplierId = 'supplierId';
  static const String colProductLowStockThreshold = 'lowStockThreshold';

  // Sync Queue Table
  static const String tableSyncQueue = 'sync_queue';
  static const String colSyncId = 'sync_id';
  static const String colSyncAction = 'action'; // 'ADD', 'UPDATE', 'DELETE'
  static const String colSyncPayload = 'payload';
  static const String colSyncTimestamp = 'timestamp';
  
  // Supplier Columns
  static const String colSupplierId = 'id';
  static const String colSupplierName = 'name';
  static const String colSupplierContactPerson = 'contactPerson';
  static const String colSupplierEmail = 'email';
  static const String colSupplierPhone = 'phone';
  static const String colSupplierAddress = 'address';

  // Audit Logs Columns
  static const String colAuditId = 'id';
  static const String colAuditProductId = 'productId';
  static const String colAuditActionType = 'actionType';
  static const String colAuditQuantityChanged = 'quantityChanged';
  static const String colAuditTimestamp = 'timestamp';
  static const String colAuditUserId = 'userId';
  static const String colAuditNotes = 'notes';
}
