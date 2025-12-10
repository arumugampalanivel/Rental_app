import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/pdf_receipt.dart';

late String tenantName;
late String roomNo;

class RentHistoryScreen extends StatefulWidget {
  static const routeName = '/rent-history';

  const RentHistoryScreen({super.key});

  @override
  State<RentHistoryScreen> createState() => _RentHistoryScreenState();
}

class _RentHistoryScreenState extends State<RentHistoryScreen> {
  int tenantId = 0;
  String selectedFilter = "All";
  List<Map<String, dynamic>> fullHistory = [];
  List<Map<String, dynamic>> filteredHistory = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    tenantId = args["tenantId"];
    tenantId = args["tenantId"];
    tenantName = args["tenantName"]; // Auto-loaded
    roomNo = args["roomNo"]; // Auto-loaded
    loadHistory();
  }

  Future<void> loadHistory() async {
    fullHistory = await DBHelper().getRentHistory(tenantId);
    applyFilter();
  }

  void applyFilter() {
    setState(() {
      if (selectedFilter == "All") {
        filteredHistory = fullHistory;
      } else {
        filteredHistory = fullHistory
            .where((r) => r['status'] == selectedFilter)
            .toList();
      }
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Paid":
        return Colors.green;
      case "Pending":
        return Colors.red;
      case "Partial":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "Paid":
        return Icons.check_circle;
      case "Pending":
        return Icons.error;
      case "Partial":
        return Icons.pending_actions;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rent History"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: Column(
        children: [
          // FILTER BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                filterChip("All"),
                filterChip("Paid"),
                filterChip("Pending"),
                filterChip("Partial"),
              ],
            ),
          ),

          Expanded(
            child: filteredHistory.isEmpty
                ? const Center(child: Text("No rent records found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final r = filteredHistory[index];
                      final status = r['status'];

                      return Card(
                        color: getStatusColor(status).withOpacity(0.15),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            getStatusIcon(status),
                            color: getStatusColor(status),
                            size: 32,
                          ),
                          title: Text(
                            "${r['month']} — ₹${r['amount']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Status: $status\nPaid Date: ${r['paid_date']}\nNote: ${r['note'] ?? ''}",
                          ),

                          trailing: IconButton(
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.teal,
                            ),
                            onPressed: () {
                              RentReceiptPDF.generate(
                                tenantName:
                                    tenantName, // auto-loaded from arguments
                                roomNo: roomNo, // auto-loaded from arguments
                                month: r['month'],
                                amount: r['amount'],
                                paidDate: r['paid_date'],
                                status: r['status'],
                                note: r['note'] ?? "",
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String label) {
    final isSelected = selectedFilter == label;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF008080),
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onSelected: (_) {
        setState(() {
          selectedFilter = label;
          applyFilter();
        });
      },
    );
  }
}
