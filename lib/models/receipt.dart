import 'invoice.dart';
import 'payment.dart';
import 'client.dart';
import '../utils/enums.dart';

// For simplicity, a receipt object. Could be expanded to generate PDF/HTML.
class Receipt {
  final String receiptId;
  final Invoice invoice;
  final Payment paymentMade; // The specific payment this receipt is for
  final Client client;
  final DateTime generationDate;

  Receipt({
    required this.receiptId,
    required this.invoice,
    required this.paymentMade,
    required this.client,
    required this.generationDate,
  });

  // Generates a simple string representation of the receipt
  String toFormattedString() {
    return '''
    ====================================
               PAYMENT RECEIPT
    ====================================
    Receipt ID: $receiptId
    Date: ${generationDate.toIso8601String().substring(0, 10)}
    ------------------------------------
    Client: ${client.name} (ID: ${client.id})
    ${client.email != null ? 'Email: ${client.email}' : ''}
    ------------------------------------
    Invoice ID: ${invoice.id}
    Invoice Date: ${invoice.issueDate.toIso8601String().substring(0, 10)}
    Invoice Total: \$${invoice.totalAmount.toStringAsFixed(2)}
    ------------------------------------
    Payment Details:
      Payment ID: ${paymentMade.id}
      Amount Paid: \$${paymentMade.amount.toStringAsFixed(2)}
      Payment Method: ${paymentMethodToString(paymentMade.method)}
      Payment Date: ${paymentMade.paymentDate.toIso8601String().substring(0, 10)}
      ${paymentMade.transactionId != null ? 'Transaction ID: ${paymentMade.transactionId}' : ''}
    ------------------------------------
    Amount Remaining on Invoice: \$${invoice.amountDue.toStringAsFixed(2)}
    Invoice Status: ${invoiceStatusToString(invoice.status)}
    ====================================
    Thank you!
    ''';
  }

  @override
  String toString() {
    return 'Receipt(id: $receiptId, invoiceId: ${invoice.id}, paymentId: ${paymentMade.id})';
  }
}