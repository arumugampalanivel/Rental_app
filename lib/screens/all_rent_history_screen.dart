import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class AllRentHistoryScreen extends StatefulWidget {
  static const routeName = '/payment-history';

  const AllRentHistoryScreen({super.key});

  @override
  State<AllRentHistoryScreen> createState() => _AllRentHistoryScreenState();
}

class _AllRentHistoryScreenState extends State<AllRentHistoryScreen> {
  final db = DBHelper();

  List<Map<String, dynamic>> fullList = [];
  List<Map<String, dynamic>> filteredList = [];

  String selectedFilter = "All";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadAllHistory();
  }

  Future<void> loadAllHistory() async {
    final database = await db.database;

    // Fetch all rent records with tenant_id
    final rentRows = await database.query('rent_history', orderBy: 'id DESC');

    List<Map<String, dynamic>> finalData = [];

    for (var rent in rentRows) {
      int tenantId = (rent["tenant_id"] as int);

      // Fetch tenant name
      final tenantRows = await database.query(
        'tenants',
        where: 'id = ?',
        whereArgs: [tenantId],
        limit: 1,
      );

      // Fetch room number (if assigned)
      final roomRows = await database.query(
        'room',
        where: 'tenant_id = ?',
        whereArgs: [tenantId],
        limit: 1,
      );

      finalData.add({
        "tenant_id": tenantId,
        "tenant_name": tenantRows.isNotEmpty
            ? tenantRows.first["name"]
            : "Unknown",
        "room_no": roomRows.isNotEmpty ? roomRows.first["room_no"] : "-",

        "id": rent["id"],
        "month": rent["month"],
        "amount": rent["amount"],
        "status": rent["status"],
        "paid_date": rent["paid_date"],
        "note": rent["note"],
      });
    }

    setState(() {
      fullList = finalData;
      applyFilter();
    });
  }

  void applyFilter() {
    setState(() {
      filteredList = fullList.where((item) {
        bool statusMatch =
            selectedFilter == "All" || item["status"] == selectedFilter;
        bool searchMatch = item["tenant_name"]
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        return statusMatch && searchMatch;
      }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search tenant...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                searchQuery = value;
                applyFilter();
              },
            ),
          ),

          // FILTER CHIPS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              filterChip("All"),
              filterChip("Paid"),
              filterChip("Pending"),
              filterChip("Partial"),
            ],
          ),

          const SizedBox(height: 10),

          // LIST STARTS
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("No payment records found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tenant Name + Room no
                              Text(
                                "${item["tenant_name"]}  (Room ${item["room_no"]})",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF004D4D),
                                ),
                              ),
                              const SizedBox(height: 6),

                              Text(
                                "Month: ${item["month"]}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Amount: ₹${item["amount"]}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Status: ${item["status"]}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: getStatusColor(item["status"]),
                                ),
                              ),
                              Text(
                                "Paid Date: ${item["paid_date"] ?? "-"}",
                                style: const TextStyle(fontSize: 15),
                              ),

                              if (item["note"] != null &&
                                  item["note"].toString().isNotEmpty)
                                Text("Note: ${item["note"]}"),

                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/rent-history',
                                      arguments: item["tenant_id"],
                                    );
                                  },
                                  child: const Text("View Full History"),
                                ),
                              ),
                            ],
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
