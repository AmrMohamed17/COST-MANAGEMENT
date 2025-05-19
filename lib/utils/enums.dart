enum PaymentMethod {
  cash,
  creditCard,
  bankTransfer,
  paypal,
  other,
}

String paymentMethodToString(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Cash';
    case PaymentMethod.creditCard:
      return 'Credit Card';
    case PaymentMethod.bankTransfer:
      return 'Bank Transfer';
    case PaymentMethod.paypal:
      return 'PayPal';
    case PaymentMethod.other:
      return 'Other';
  }
}

enum InvoiceStatus {
  unpaid,
  partiallyPaid,
  paid,
  overdue,
  cancelled,
}

String invoiceStatusToString(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.unpaid:
      return 'Unpaid';
    case InvoiceStatus.partiallyPaid:
      return 'Partially Paid';
    case InvoiceStatus.paid:
      return 'Paid';
    case InvoiceStatus.overdue:
      return 'Overdue';
    case InvoiceStatus.cancelled:
      return 'Cancelled';
  }
}
