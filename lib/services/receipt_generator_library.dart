import '../models/receipt.dart';
import '../models/payment.dart';
import 'payment_system_manager.dart';

class ReceiptGeneratorLibrary {
  final PaymentSystemManager _manager;

  ReceiptGeneratorLibrary(this._manager);

  /// Generates a receipt object for a specific payment made against an invoice.
  /// Inputs: Invoice ID, Payment details (or Payment ID if payments are globally unique and findable).
  /// For this implementation, we'll assume the Payment object itself is passed,
  /// typically one returned by `logPayment`.
  Receipt? generateReceipt({
    required String invoiceId, // To fetch the full invoice context
    required Payment
        paymentMade, // The specific payment for which receipt is generated
  }) {
    final invoice = _manager.getInvoiceById(invoiceId);
    if (invoice == null) {
      print('Error [ReceiptGenerator]: Invoice $invoiceId not found.');
      return null;
    }

    // Verify the payment belongs to this invoice
    if (!invoice.payments.any((p) => p.id == paymentMade.id)) {
      print(
          'Error [ReceiptGenerator]: Payment ${paymentMade.id} does not belong to Invoice $invoiceId.');
      return null;
    }

    final client = _manager.getClientById(invoice.clientId);
    if (client == null) {
      print(
          'Error [ReceiptGenerator]: Client ${invoice.clientId} for Invoice $invoiceId not found.');
      return null;
    }

    final receiptId =
        'RCPT-${DateTime.now().millisecondsSinceEpoch}-${paymentMade.id.substring(0, 5)}';

    final receipt = Receipt(
      receiptId: receiptId,
      invoice: invoice,
      paymentMade: paymentMade,
      client: client,
      generationDate: DateTime.now(),
    );

    print(
        'Receipt generated: ${receipt.receiptId} for Payment ${paymentMade.id}');
    return receipt;
  }
}
