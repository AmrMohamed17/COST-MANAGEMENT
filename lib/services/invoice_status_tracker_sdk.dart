import '../utils/enums.dart';
import 'payment_system_manager.dart'; // To access invoices

class InvoiceStatusTrackerSDK {
  final PaymentSystemManager _manager;

  InvoiceStatusTrackerSDK(this._manager);

  /// Updates the status of a specific invoice.
  /// Optionally recalculates based on payments and due date.
  /// Returns true if status was changed, false otherwise.
  bool updateInvoiceStatus(String invoiceId, InvoiceStatus newStatus, {bool skipRecalculate = false}) {
    final invoice = _manager.getInvoiceById(invoiceId);
    if (invoice == null) {
      print('Error [StatusTracker]: Invoice $invoiceId not found.');
      return false;
    }

    if (skipRecalculate) {
        if (invoice.status != newStatus) {
            invoice.status = newStatus;
            print('Invoice $invoiceId status explicitly set to: ${invoiceStatusToString(newStatus)}');
            return true;
        }
        return false;
    }
    
    // If not skipping, recalculate will handle setting the status
    return recalculateInvoiceStatus(invoiceId);
  }

  /// Recalculates and updates the invoice status based on payments and due date.
  /// Returns true if status was changed, false otherwise.
  bool recalculateInvoiceStatus(String invoiceId) {
    final invoice = _manager.getInvoiceById(invoiceId);
    if (invoice == null) {
      print('Error [StatusTracker]: Invoice $invoiceId not found for recalculation.');
      return false;
    }

    // Do not change status if it's cancelled
    if (invoice.status == InvoiceStatus.cancelled) {
        print('Invoice $invoiceId is Cancelled. Status not changed by recalculation.');
        return false;
    }

    InvoiceStatus determinedStatus;
    final amountPaid = invoice.amountPaid;

    if (amountPaid >= invoice.totalAmount) {
      determinedStatus = InvoiceStatus.paid;
    } else if (amountPaid > 0) {
      determinedStatus = InvoiceStatus.partiallyPaid;
    } else {
      determinedStatus = InvoiceStatus.unpaid;
    }

    // Check for overdue status, but only if not already paid
    if (determinedStatus != InvoiceStatus.paid && DateTime.now().isAfter(invoice.dueDate)) {
      determinedStatus = InvoiceStatus.overdue;
    }
    
    if (invoice.status != determinedStatus) {
      invoice.status = determinedStatus;
      print('Invoice $invoiceId status recalculated to: ${invoiceStatusToString(determinedStatus)}');
      return true;
    }
    return false;
  }

  /// Gets the current status of an invoice.
  InvoiceStatus? getInvoiceStatus(String invoiceId) {
    final invoice = _manager.getInvoiceById(invoiceId);
    if (invoice == null) {
      print('Error [StatusTracker]: Invoice $invoiceId not found.');
      return null;
    }
    // Optionally, always recalculate before returning for utmost accuracy,
    // though this might be performance-intensive if called frequently.
    // recalculateInvoiceStatus(invoiceId); 
    return invoice.status;
  }
}