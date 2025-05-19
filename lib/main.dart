import 'package:flutter/material.dart';
import 'models/client.dart';
import 'models/invoice.dart';
import 'models/payment.dart';
import 'models/receipt.dart';
import 'models/report.dart';
import 'services/payment_system_manager.dart';
import 'utils/enums.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment System Pro', // New Name!
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Changed theme color
        brightness: Brightness.light, // Let's try a light theme for a change
        // brightness: Brightness.dark, // Or keep dark if preferred
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          // fillColor: Colors.black.withOpacity(0.05), // For dark theme
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const PaymentDemoPage(),
    );
  }
}

class PaymentDemoPage extends StatefulWidget {
  const PaymentDemoPage({super.key});

  @override
  State<PaymentDemoPage> createState() => _PaymentDemoPageState();
}

class _PaymentDemoPageState extends State<PaymentDemoPage> {
  final PaymentSystemManager manager = PaymentSystemManager();
  final ScrollController _logScrollController = ScrollController();

  String _logOutput = "Welcome! Initialize data or perform actions.\n";
  Invoice? _selectedInvoice;
  Client? _selectedClient;
  Payment? _lastPayment;
  Receipt? _lastReceipt;
  InvoiceSummaryReport? _lastReport;

  List<Client> _clients = [];
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  void _log(String message) {
    print(message);
    setState(() {
      // Append new messages to the end for chronological order
      _logOutput = "$_logOutput\n${DateTime.now().toIso8601String().substring(11,19)}: $message";
      // Basic log trimming
      if (_logOutput.length > 5000) {
        _logOutput = _logOutput.substring(_logOutput.length - 5000);
      }
    });
    // Auto-scroll to the bottom of the log
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _refreshData() {
    setState(() {
      _clients = manager.getAllClients();
      _invoices = manager.getAllInvoices();
      // Potentially re-select or clear selection if items are removed
      if (_selectedClient != null && !_clients.any((c) => c.id == _selectedClient!.id)) {
        _selectedClient = _clients.isNotEmpty ? _clients.first : null;
      }
      if (_selectedInvoice != null && !_invoices.any((inv) => inv.id == _selectedInvoice!.id)) {
        _selectedInvoice = _invoices.isNotEmpty ? _invoices.first : null;
      }
    });
  }

  void _initializeData() {
    final client1 = Client(id: 'C001', name: 'Alice Wonderland', email: 'alice@example.com');
    final client2 = Client(id: 'C002', name: 'Bob The Builder');
    manager.addClient(client1);
    manager.addClient(client2);
    
    final invoice1 = Invoice(
      id: 'INV001',
      clientId: client1.id,
      totalAmount: 150.00,
      issueDate: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().add(const Duration(days: 20)),
    );
    final invoice2 = Invoice(
      id: 'INV002',
      clientId: client2.id,
      totalAmount: 300.00,
      issueDate: DateTime.now().subtract(const Duration(days: 35)),
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
    );
    final invoice3 = Invoice(
      id: 'INV003',
      clientId: client1.id,
      totalAmount: 75.50,
      issueDate: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 10)),
    );

    manager.addInvoice(invoice1);
    manager.addInvoice(invoice2);
    manager.addInvoice(invoice3);
    
    _refreshData(); // Update local lists and potentially default selections
    
    if (_clients.isNotEmpty) _selectedClient = _clients.first;
    if (_invoices.isNotEmpty) _selectedInvoice = _invoices.first;

    _log('Initialized Clients: ${_clients.map((c) => c.name).join(', ')}');
    _log('Initialized Invoices: ${_invoices.map((inv) => inv.id).join(', ')}');
    _log('--- Initial State ---');
    for (var inv in _invoices) {
        _log(inv.toString());
    }
    _log('--------------------');
  }
  
  void _logPaymentDemo() {
    if (_selectedInvoice == null) {
      _log('No invoice selected to log payment.');
      return;
    }
    _log('--- Logging Payment for ${_selectedInvoice!.id} ---');
    _lastPayment = manager.paymentLogger.logPayment(
      invoiceId: _selectedInvoice!.id,
      amount: 50.0, // You could make this an input field
      method: PaymentMethod.creditCard,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
    if (_lastPayment != null) {
      _log('Payment logged: \$50.00. New Balance: \$${_selectedInvoice!.amountDue.toStringAsFixed(2)}');
      _log('Updated Invoice: ${manager.getInvoiceById(_selectedInvoice!.id)}');
    } else {
      _log('Failed to log payment for ${_selectedInvoice!.id}.');
    }
    _refreshData(); // Refresh invoice list to show status changes
    setState(() {}); // Ensure UI rebuilds to show new _lastPayment
  }

  void _generateReceiptDemo() {
    if (_selectedInvoice == null || _lastPayment == null) {
      _log('Cannot generate receipt. Log a payment first or ensure invoice and last payment are set.');
      return;
    }
    _log('--- Generating Receipt for Payment ${_lastPayment!.id} ---');
    _lastReceipt = manager.receiptGenerator.generateReceipt(
      invoiceId: _selectedInvoice!.id,
      paymentMade: _lastPayment!,
    );
    if (_lastReceipt != null) {
      _log('Receipt generated: ${_lastReceipt!.receiptId}.');
      // _log('Receipt Details:\n${_lastReceipt!.toFormattedString()}'); // Logged below
    } else {
      _log('Failed to generate receipt.');
    }
    setState(() {});
  }
  
  void _viewPaymentHistoryDemo() {
    if (_selectedInvoice == null) {
      _log('No invoice selected to view history.');
      return;
    }
    _log('--- Payment History for Invoice ${_selectedInvoice!.id} ---');
    final history = manager.paymentHistoryLog.getPaymentHistory(_selectedInvoice!.id);
    if (history.isEmpty) {
      _log('No payments found for this invoice.');
    } else {
      for (var p in history) {
        _log(p.toString());
      }
    }
  }

  void _checkInvoiceStatusDemo() {
    if (_selectedInvoice == null) {
      _log('No invoice selected to check status.');
      return;
    }
    _log('--- Checking/Updating Invoice Status for ${_selectedInvoice!.id} ---');
    manager.invoiceStatusTracker.recalculateInvoiceStatus(_selectedInvoice!.id);
    final status = manager.invoiceStatusTracker.getInvoiceStatus(_selectedInvoice!.id);
    if (status != null) {
      _log('Invoice ${_selectedInvoice!.id} status: ${invoiceStatusToString(status)}');
      _log('Full Invoice Details: ${manager.getInvoiceById(_selectedInvoice!.id)}');
    } else {
      _log('Could not get status for invoice ${_selectedInvoice!.id}');
    }
    _refreshData(); // Refresh invoice list to show status changes
    setState(() {});
  }
  
  void _generateReportAllDemo() {
    _log('--- Generating Report (All Invoices) ---');
    _lastReport = manager.invoiceSummaryReport.generateReport();
    _log('Report Generated: "${_lastReport!.title}" with ${_lastReport!.invoices.length} invoices.');
    setState(() {});
  }

  void _generateReportFilteredDemo() {
    if (_selectedClient == null && _selectedInvoice == null) {
      _log('Select a client or an invoice for filtered report context.');
      // return; // Or allow empty filters
    }
    _log('--- Generating Report (Filtered) ---');
    _lastReport = manager.invoiceSummaryReport.generateReport(
      clientIdFilter: _selectedClient?.id, // Use selected client if available
      statusFilter: _selectedInvoice?.status, // Use selected invoice's status as an example filter
      // startDate: DateTime.now().subtract(Duration(days: 30))
    );
    _log('Report Generated: "${_lastReport!.title}" with ${_lastReport!.invoices.length} invoices.');
    setState(() {});
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          if (icon != null) const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildClientSelector() {
    return DropdownButtonFormField<Client>(
      decoration: const InputDecoration(labelText: 'Select Client', prefixIcon: Icon(Icons.person_outline)),
      value: _selectedClient,
      items: _clients.map((Client client) {
        return DropdownMenuItem<Client>(
          value: client,
          child: Text(client.name),
        );
      }).toList(),
      onChanged: (Client? newValue) {
        setState(() {
          _selectedClient = newValue;
          // Optionally filter invoices if a client is selected
          // _selectedInvoice = null; // Or find first invoice for this client
        });
        _log('Client selected: ${newValue?.name ?? "None"}');
      },
      isExpanded: true,
    );
  }

  Widget _buildInvoiceSelector() {
    // Filter invoices by selected client if a client is chosen
    List<Invoice> displayInvoices = _invoices;
    // if (_selectedClient != null) {
    //   displayInvoices = _invoices.where((inv) => inv.clientId == _selectedClient!.id).toList();
    // }
    
    return DropdownButtonFormField<Invoice>(
      decoration: const InputDecoration(labelText: 'Select Invoice', prefixIcon: Icon(Icons.receipt_long_outlined)),
      value: _selectedInvoice,
      // Ensure selectedInvoice is in the list of items if filtered
      items: displayInvoices.map((Invoice invoice) {
        return DropdownMenuItem<Invoice>(
          value: invoice,
          child: Text('${invoice.id} - \$${invoice.totalAmount.toStringAsFixed(2)} (${invoiceStatusToString(invoice.status)})', overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (Invoice? newValue) {
        setState(() {
          _selectedInvoice = newValue;
          if (newValue != null) {
            // Auto-select client if an invoice is chosen
            _selectedClient = _clients.firstWhere((c) => c.id == newValue.clientId);
          }
        });
        _log('Invoice selected: ${newValue?.id ?? "None"}');
      },
      isExpanded: true,
    );
  }
  
  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: <Widget>[
        ElevatedButton.icon(icon: const Icon(Icons.payment), onPressed: _logPaymentDemo, label: const Text('Log \$50 Payment')),
        ElevatedButton.icon(icon: const Icon(Icons.receipt), onPressed: _generateReceiptDemo, label: const Text('Generate Receipt')),
        ElevatedButton.icon(icon: const Icon(Icons.history), onPressed: _viewPaymentHistoryDemo, label: const Text('View History')),
        ElevatedButton.icon(icon: const Icon(Icons.fact_check_outlined), onPressed: _checkInvoiceStatusDemo, label: const Text('Check Status')),
        ElevatedButton.icon(icon: const Icon(Icons.assessment_outlined), onPressed: _generateReportAllDemo, label: const Text('Report (All)')),
        ElevatedButton.icon(icon: const Icon(Icons.filter_alt_outlined), onPressed: _generateReportFilteredDemo, label: const Text('Report (Filtered)')),
      ],
    );
  }

  Widget _buildInfoTile(String title, String subtitle, {IconData? icon}) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.primary) : null,
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      dense: true,
    );
  }

  Widget _buildSelectedDetailsCard() {
    if (_selectedInvoice == null && _selectedClient == null) {
      return const SizedBox.shrink(); // Hide if nothing is selected
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Selection Details", icon: Icons.info_outline),
            if (_selectedClient != null) ...[
              _buildInfoTile("Selected Client", "${_selectedClient!.name} (ID: ${_selectedClient!.id})", icon: Icons.person),
              if (_selectedClient!.email != null) _buildInfoTile("Client Email", _selectedClient!.email!),
            ],
            if (_selectedClient != null && _selectedInvoice != null) const Divider(height: 20),
            if (_selectedInvoice != null) ...[
              _buildInfoTile("Selected Invoice", _selectedInvoice!.id, icon: Icons.receipt_long),
              _buildInfoTile("Invoice Total", "\$${_selectedInvoice!.totalAmount.toStringAsFixed(2)}"),
              _buildInfoTile("Amount Paid", "\$${_selectedInvoice!.amountPaid.toStringAsFixed(2)}"),
              _buildInfoTile("Amount Due", "\$${_selectedInvoice!.amountDue.toStringAsFixed(2)}", icon: Icons.attach_money),
              _buildInfoTile("Status", invoiceStatusToString(_selectedInvoice!.status), icon: _selectedInvoice!.status == InvoiceStatus.paid ? Icons.check_circle_outline : Icons.hourglass_empty_outlined),
              _buildInfoTile("Issue Date", _selectedInvoice!.issueDate.toIso8601String().substring(0,10)),
              _buildInfoTile("Due Date", _selectedInvoice!.dueDate.toIso8601String().substring(0,10)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastOperationResultsCard() {
    bool hasResults = _lastPayment != null || _lastReceipt != null || _lastReport != null;
    if (!hasResults) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildSectionTitle("Last Operation Results", icon: Icons.dynamic_feed),
            if (_lastPayment != null) ...[
              _buildInfoTile("Last Payment Logged", "ID: ${_lastPayment!.id}", icon: Icons.payment),
              _buildInfoTile("Amount", "\$${_lastPayment!.amount.toStringAsFixed(2)} by ${paymentMethodToString(_lastPayment!.method)}"),
              const Divider(height: 20),
            ],
            if (_lastReceipt != null) ...[
              _buildInfoTile("Last Receipt Generated", "ID: ${_lastReceipt!.receiptId}", icon: Icons.receipt),
              TextButton(
                child: const Text("View Full Receipt Details in Log"),
                onPressed: () => _log("--- Last Receipt ---\n${_lastReceipt!.toFormattedString()}"),
              ),
              const Divider(height: 20),
            ],
            if (_lastReport != null) ...[
              _buildInfoTile("Last Report Generated", _lastReport!.title, icon: Icons.assessment),
              _buildInfoTile("Invoices Found", "${_lastReport!.invoices.length}"),
              TextButton(
                child: const Text("View Full Report Details in Log"),
                onPressed: () => _log("--- Last Report ---\n${_lastReport!.toFormattedString()}"),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildLogOutputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Less padding for log content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0), // Padding for title
              child: _buildSectionTitle("Activity Log", icon: Icons.terminal),
            ),
            Container(
              height: 250, // Fixed height for the log area
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor)
              ),
              child: Scrollbar(
                controller: _logScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _logScrollController,
                  child: Text(_logOutput, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment System Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _initializeData(); // Re-initialize or just refresh
              _log("Data re-initialized.");
            },
            tooltip: "Reset Data",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSectionTitle("Selections", icon: Icons.ads_click),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildClientSelector(),
                    const SizedBox(height: 16),
                    _buildInvoiceSelector(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
             _buildSectionTitle("Actions", icon: Icons.play_circle_outline),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildActionButtons(),
              ),
            ),
            const SizedBox(height: 16),
            _buildSelectedDetailsCard(),
            _buildLastOperationResultsCard(),
            const SizedBox(height: 16),
            _buildLogOutputCard(),
          ],
        ),
      ),
    );
  }
}