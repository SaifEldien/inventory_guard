import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import '../../features/products/domain/entities/product.dart';

class ImportExportHelper {
  /// Exports a list of products to a CSV file and triggers download on Web
  static void exportProductsToCsv(List<Product> products) {
    List<List<dynamic>> rows = [
      [
        'ID',
        'Name',
        'SKU',
        'Category',
        'Quantity',
        'UnitPrice',
        'SupplierID',
        'WarehouseID',
        'LowStockThreshold'
      ]
    ];

    for (var p in products) {
      rows.add([
        p.id,
        p.name,
        p.sku,
        p.category,
        p.quantity,
        p.unitPrice,
        p.supplierId,
        p.warehouseId,
        p.lowStockThreshold,
      ]);
    }

    // Using Csv() class from package:csv 8.0.0
    String csv = Csv().encode(rows);

    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "inventory_export_${DateTime.now().millisecondsSinceEpoch}.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      debugPrint('Export to CSV is currently optimized for Web.');
    }
  }

  /// Picks a CSV file and returns a list of Product maps
  static Future<List<Map<String, dynamic>>?> importProductsFromCsv() async {
    try {
      // file_picker 11.0.0+ uses static pickFiles() method
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final content = utf8.decode(result.files.single.bytes!);
        // Using Csv() class from package:csv 8.0.0
        List<List<dynamic>> rows = Csv().decode(content);

        if (rows.isEmpty) return null;

        List<String> headers = rows[0].map((e) => e.toString()).toList();
        List<Map<String, dynamic>> products = [];

        for (int i = 1; i < rows.length; i++) {
          Map<String, dynamic> productMap = {};
          for (int j = 0; j < headers.length; j++) {
            if (j < rows[i].length) {
              productMap[headers[j]] = rows[i][j];
            }
          }
          products.add(productMap);
        }
        return products;
      }
    } catch (e) {
      debugPrint('Error importing CSV: $e');
    }
    return null;
  }
}
