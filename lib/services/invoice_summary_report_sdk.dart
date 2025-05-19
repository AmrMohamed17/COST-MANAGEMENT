import '../models/invoice.dart';
import '../models/report.dart';
import '../utils/enums.dart';
import 'payment_system_manager.dart';

class InvoiceSummaryReportSDK {
  final PaymentSystemManager _manager;

  InvoiceSummaryReportSDK(this._manager);

  /// Generates reports summarizing invoices by status, client, or date range.
  InvoiceSummaryReport generateReport({
    DateTime? startDate,
    DateTime? endDate,
    InvoiceStatus? statusFilter,
    String? clientIdFilter,
  }) {
    List<Invoice> allInvoices = _manager.getAllInvoices();
    List<Invoice> filteredInvoices =
        List.from(allInvoices); // Start with all, then filter

    Map<String, dynamic> filtersApplied = {};

    // Apply date range filter (on issueDate for this example)
    if (startDate != null) {
      filteredInvoices = filteredInvoices
          .where((inv) =>
              inv.issueDate.isAtSameMomentAs(startDate) ||
              inv.issueDate.isAfter(startDate))
          .toList();
      filtersApplied['Start Date'] =
          startDate.toIso8601String().substring(0, 10);
    }
    if (endDate != null) {
      // Adjust endDate to include the whole day
      DateTime effectiveEndDate =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      filteredInvoices = filteredInvoices
          .where((inv) =>
              inv.issueDate.isAtSameMomentAs(effectiveEndDate) ||
              inv.issueDate.isBefore(effectiveEndDate))
          .toList();
      filtersApplied['End Date'] = endDate.toIso8601String().substring(0, 10);
    }

    // Apply status filter
    if (statusFilter != null) {
      filteredInvoices =
          filteredInvoices.where((inv) => inv.status == statusFilter).toList();
      filtersApplied['Status'] = invoiceStatusToString(statusFilter);
    }

    // Apply client ID filter
    if (clientIdFilter != null && clientIdFilter.isNotEmpty) {
      filteredInvoices = filteredInvoices
          .where((inv) => inv.clientId == clientIdFilter)
          .toList();
      filtersApplied['Client ID'] = clientIdFilter;
    }

    // For complex reports, you might group or aggregate here.
    // For this example, the report object just contains the list of filtered invoices.

    String reportTitle = "Invoice Summary";
    if (filtersApplied.isNotEmpty) {
      reportTitle += " (Filtered)";
    }

    final report = InvoiceSummaryReport(
      title: reportTitle,
      filtersApplied: filtersApplied,
      invoices: filteredInvoices,
      generationDate: DateTime.now(),
    );

    print(
        'Report generated: "${report.title}" with ${report.invoices.length} invoices.');
    return report;
  }
}
