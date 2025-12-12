import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '/screens/add_rent_screen.dart';

class RentHistoryScreen extends StatefulWidget {
  static const String routeName = '/rent-history';

  const RentHistoryScreen({super.key});

  @override
  State<RentHistoryScreen> createState() => _RentHistoryScreenState();
}

class _RentHistoryScreenState extends State<RentHistoryScreen> {
  final db = DBHelper();

  int tenantId = 0;
  List<Map<String, dynamic>> rentList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tenantId = ModalRoute.of(context)!.settings.arguments as int;
    loadRentHistory();
  }

  Future<void> loadRentHistory() async {
    final data = await db.getRentHistory(tenantId);
    setState(() {
      rentList = data;
    });
  }

  Future<void> deleteRent(int id) async {
    final database = await db.database;
    await database.delete('rent_history', where: 'id = ?', whereArgs: [id]);

    loadRentHistory();
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
        title: const Text("Rent History"),
        backgroundColor: const Color(0xFF008080),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF008080),
        child: const Icon(Icons.add),
        onPressed: () async {
          bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRentScreen(tenantId: tenantId),
            ),
          );
          if (refresh == true) loadRentHistory();
        },
      ),

      body: rentList.isEmpty
          ? const Center(child: Text("No rent history yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: rentList.length,
              itemBuilder: (context, index) {
                final rent = rentList[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month
                        Text(
                          rent["month"] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004D4D),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Amount
                        Text(
                          "Amount: ₹${rent["amount"]}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Status with color
                        Text(
                          "Status: ${rent["status"]}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(rent["status"]),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Paid Date
                        Text(
                          "Paid Date: ${rent["paid_date"] ?? "-"}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 6),

                        // Notes
                        if (rent["note"] != null &&
                            rent["note"].toString().isNotEmpty)
                          Text(
                            "Notes: ${rent["note"]}",
                            style: const TextStyle(fontSize: 15),
                          ),

                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // TODO: Implement Edit Rent
                              },
                              child: const Text("Edit"),
                            ),
                            TextButton(
                              onPressed: () => deleteRent(rent["id"]),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
