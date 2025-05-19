import '../models/client.dart';
import '../models/invoice.dart';
import 'invoice_status_tracker_sdk.dart';
import 'payment_logger_sdk.dart';
import 'payment_history_log_library.dart';
import 'receipt_generator_library.dart';
import 'invoice_summary_report_sdk.dart';

class PaymentSystemManager {
  // In-memory data stores
  final List<Client> _clients = [];
  final List<Invoice> _invoices = [];

  late final PaymentLoggerSDK paymentLogger;
  late final ReceiptGeneratorLibrary receiptGenerator;
  late final InvoiceStatusTrackerSDK invoiceStatusTracker;
  late final PaymentHistoryLogLibrary paymentHistoryLog;
  late final InvoiceSummaryReportSDK invoiceSummaryReport;

  PaymentSystemManager() {
    // Initialize SDKs, passing a reference to this manager or directly to data stores
    // if they need to operate on them.
    invoiceStatusTracker = InvoiceStatusTrackerSDK(this);
    paymentLogger = PaymentLoggerSDK(this, invoiceStatusTracker);
    receiptGenerator = ReceiptGeneratorLibrary(this);
    paymentHistoryLog = PaymentHistoryLogLibrary(this);
    invoiceSummaryReport = InvoiceSummaryReportSDK(this);
  }

  // --- Data Management Methods (for this example) ---
  void addClient(Client client) {
    if (!_clients.any((c) => c.id == client.id)) {
      _clients.add(client);
      print('Client added: ${client.name}');
    } else {
      print('Client with ID ${client.id} already exists.');
    }
  }

  Client? getClientById(String clientId) {
    try {
      return _clients.firstWhere((c) => c.id == clientId);
    } catch (e) {
      return null;
    }
  }

  List<Client> getAllClients() => List.unmodifiable(_clients);


  void addInvoice(Invoice invoice) {
    if (!_invoices.any((inv) => inv.id == invoice.id)) {
      _invoices.add(invoice);
      // Initial status check (e.g., for overdue)
      invoiceStatusTracker.updateInvoiceStatus(invoice.id, invoice.status, skipRecalculate: true);
      invoiceStatusTracker.recalculateInvoiceStatus(invoice.id); // Ensure overdue is checked
      print('Invoice added: ${invoice.id} for client ${invoice.clientId}');
    } else {
      print('Invoice with ID ${invoice.id} already exists.');
    }
  }

  Invoice? getInvoiceById(String invoiceId) {
    try {
      return _invoices.firstWhere((inv) => inv.id == invoiceId);
    } catch (e) {
      return null;
    }
  }
  
  List<Invoice> getAllInvoices() => List.unmodifiable(_invoices);


  // --- SDK Accessors (if needed, or use directly) ---
  // These are already public: paymentLogger, receiptGenerator, etc.
}