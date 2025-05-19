import '../models/payment.dart';
import 'payment_system_manager.dart';

class PaymentHistoryLogLibrary {
  final PaymentSystemManager _manager;

  PaymentHistoryLogLibrary(this._manager);

  /// Retrieves a comprehensive list of payments for a given invoice.
  List<Payment> getPaymentHistory(String invoiceId) {
    final invoice = _manager.getInvoiceById(invoiceId);
    if (invoice == null) {
      print('Error [PaymentHistory]: Invoice $invoiceId not found.');
      return []; // Return empty list if invoice not found
    }
    // The payments are already part of the invoice object.
    // This library method formalizes access to them.
    return List.unmodifiable(
        invoice.payments); // Return a copy to prevent external modification
  }
}
