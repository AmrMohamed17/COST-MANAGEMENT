import '../utils/enums.dart';

class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final PaymentMethod method;
  final DateTime paymentDate;
  final String? transactionId; // Optional transaction reference

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.paymentDate,
    this.transactionId,
  });

  @override
  String toString() {
    return 'Payment(id: $id, invoiceId: $invoiceId, amount: $amount, method: ${paymentMethodToString(method)}, date: $paymentDate, transactionId: $transactionId)';
  }
}