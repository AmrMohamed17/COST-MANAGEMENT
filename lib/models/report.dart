import 'invoice.dart';
import '../utils/enums.dart';


class InvoiceSummaryReport {
  final String title;
  final Map<String, dynamic> filtersApplied;
  final List<Invoice> invoices; // Could be aggregated data too
  final DateTime generationDate;

  InvoiceSummaryReport({
    required this.title,
    required this.filtersApplied,
    required this.invoices,
    required this.generationDate,
  });

  String toFormattedString() {
    final StringBuffer sb = StringBuffer();
    sb.writeln('====================================');
    sb.writeln('      INVOICE SUMMARY REPORT');
    sb.writeln('====================================');
    sb.writeln('Title: $title');
    sb.writeln('Generated: ${generationDate.toIso8601String().substring(0, 10)}');
    sb.writeln('Filters Applied:');
    filtersApplied.forEach((key, value) {
      if (value != null) {
        sb.writeln('  - $key: $value');
      }
    });
    sb.writeln('------------------------------------');
    if (invoices.isEmpty) {
      sb.writeln('No invoices found matching criteria.');
    } else {
      sb.writeln('Found ${invoices.length} Invoices:');
      for (var invoice in invoices) {
        sb.writeln(
            '  ID: ${invoice.id}, Client: ${invoice.clientId}, Amount: \$${invoice.totalAmount.toStringAsFixed(2)}, Status: ${invoiceStatusToString(invoice.status)}, Due: ${invoice.dueDate.toIso8601String().substring(0, 10)}');
      }
    }
    sb.writeln('====================================');
    return sb.toString();
  }

  @override
  String toString() {
    return 'InvoiceSummaryReport(title: $title, invoicesCount: ${invoices.length})';
  }
}