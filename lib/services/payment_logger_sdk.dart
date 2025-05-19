import '../models/payment.dart';
import '../utils/enums.dart';
import 'payment_system_manager.dart';
import 'invoice_status_tracker_sdk.dart'; // To update status after payment

class PaymentLoggerSDK {
  final PaymentSystemManager _manager;
  final InvoiceStatusTrackerSDK _statusTracker;

  PaymentLoggerSDK(this._manager, this._statusTracker);

  /// Logs a payment against a specific invoice.
  /// Returns the created Payment object if successful, null otherwise.
  Payment? logPayment({
    required String invoiceId,
    required double amount,
    required PaymentMethod method,
    String? transactionId, // Optional
  }) {
    final invoice = _manager.getInvoiceById(invoiceId);
    if (invoice == null) {
      print('Error [PaymentLogger]: Invoice $invoiceId not found. Payment not logged.');
      return null;
    }

    if (invoice.status == InvoiceStatus.paid) {
        print('Warning [PaymentLogger]: Invoice $invoiceId is already Paid. Logging overpayment or refund scenario?');
        // Allow logging for now, could add specific logic for overpayments/refunds
    }
    if (invoice.status == InvoiceStatus.cancelled) {
        print('Error [PaymentLogger]: Invoice $invoiceId is Cancelled. Cannot log payment.');
        return null;
    }

    if (amount <= 0) {
      print('Error [PaymentLogger]: Payment amount must be positive. Payment not logged.');
      return null;
    }

    final paymentId = 'PAY-${DateTime.now().millisecondsSinceEpoch}-${invoice.payments.length + 1}';
    final newPayment = Payment(
      id: paymentId,
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      paymentDate: DateTime.now(),
      transactionId: transactionId,
    );

    invoice.payments.add(newPayment);
    print('Payment logged: ${newPayment.id} for Invoice ${invoice.id}, Amount: \$${amount.toStringAsFixed(2)}');

    // Update invoice status after logging payment
    _statusTracker.recalculateInvoiceStatus(invoiceId);

    // Output: Updated payment history for the invoice (achieved by modifying invoice.payments)
    return newPayment;
  }
}