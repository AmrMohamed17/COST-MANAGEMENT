import 'payment.dart';
import '../utils/enums.dart';

class Invoice {
  final String id;
  final String clientId;
  final double totalAmount;
  final DateTime issueDate;
  final DateTime dueDate;
  InvoiceStatus status;
  final List<Payment> payments; 

  Invoice({
    required this.id,
    required this.clientId,
    required this.totalAmount,
    required this.issueDate,
    required this.dueDate,
    this.status = InvoiceStatus.unpaid,
    List<Payment>? payments,
  }) : payments = payments ?? [];

  double get amountPaid {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double get amountDue {
    return totalAmount - amountPaid;
  }

  @override
  String toString() {
    return 'Invoice(id: $id, clientId: $clientId, totalAmount: $totalAmount, amountPaid: $amountPaid, amountDue: $amountDue, status: ${invoiceStatusToString(status)}, issueDate: $issueDate, dueDate: $dueDate, paymentsCount: ${payments.length})';
  }
}