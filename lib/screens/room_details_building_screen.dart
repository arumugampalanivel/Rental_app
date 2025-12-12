import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/room_model.dart';

class RoomDetailsBuildingScreen extends StatefulWidget {
  static const String routeName = '/room-details-building';

  const RoomDetailsBuildingScreen({super.key});

  @override
  State<RoomDetailsBuildingScreen> createState() =>
      _RoomDetailsBuildingScreenState();
}

class _RoomDetailsBuildingScreenState extends State<RoomDetailsBuildingScreen> {
  final db = DBHelper();

  RoomModel? room;
  List<Map<String, dynamic>> occupants = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    room = ModalRoute.of(context)!.settings.arguments as RoomModel;
    loadOccupants();
  }

  // 🔥 Load all occupants + update room status automatically
  Future<void> loadOccupants() async {
    final database = await db.database;

    // 1️⃣ Fetch tenant assignments from "room" table
    final assignmentRows = await database.query(
      'room',
      where: 'room_no = ?',
      whereArgs: [room!.roomNo],
    );

    List<Map<String, dynamic>> tenantDetailsList = [];

    for (var r in assignmentRows) {
      int tenantId = r["tenant_id"] is int
          ? r["tenant_id"] as int
          : int.parse(r["tenant_id"].toString());

      // 2️⃣ Fetch tenant details from "tenants" table
      final tenantRows = await database.query(
        'tenants',
        where: 'id = ?',
        whereArgs: [tenantId],
        limit: 1,
      );

      if (tenantRows.isNotEmpty) {
        final tenant = tenantRows.first;

        // 3️⃣ Combine tenant + assignment data
        tenantDetailsList.add({
          "tenant_id": tenantId, // Required for delete
          "name": tenant["name"] ?? "",
          "mobile": tenant["mobile"] ?? "",
          "advance": r["advance"] ?? "",
          "rent": r["rent"] ?? "",
          "rent_date": r["rent_date"] ?? "",
          "notes": r["notes"] ?? "",
        });
      }
    }

    // 4️⃣ Update room status depending on occupancy
    if (tenantDetailsList.isEmpty) {
      await db.updateRoom(room!.id!, {"status": "Available"});
    } else {
      await db.updateRoom(room!.id!, {"status": "Occupied"});
    }

    // 5️⃣ Update UI
    // 🔥 Auto-update room status in DB
    if (tenantDetailsList.isEmpty) {
      await db.updateRoom(room!.id!, {"status": "Available"});
    } else {
      await db.updateRoom(room!.id!, {"status": "Occupied"});
    }

    setState(() {
      occupants = tenantDetailsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (room == null) return const SizedBox();

    int current = occupants.length;
    int max = room!.maxOccupants;

    String status = room!.status;
    Color statusColor = status == "Available" ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text("Room ${room!.roomNo}"),
        backgroundColor: const Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ROOM INFO
            info("Room Number", room!.roomNo),
            info("Floor", room!.floor),
            info("Location", room!.location),
            info("Advance", "₹${room!.advance}"),
            info("Rent", "₹${room!.rent}"),
            info("Max Occupants", "$max"),
            info("Notes", room!.notes.isEmpty ? "—" : room!.notes),

            const SizedBox(height: 12),

            // ROOM STATUS
            Text(
              "Status: $status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // OCCUPANTS HEADER
            Text(
              "Current Occupants ($current / $max)",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005B5B),
              ),
            ),

            const SizedBox(height: 10),

            // OCCUPANTS LIST
            occupants.isEmpty
                ? const Text("No tenants currently living here")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: occupants.length,
                    itemBuilder: (context, index) {
                      final t = occupants[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t["name"],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Mobile: ${t["mobile"]}"),
                              Text("Advance Paid: ₹${t["advance"]}"),
                              Text("Rent: ₹${t["rent"]}"),
                              Text("Rent Paying Date: ${t["rent_date"]}"),
                              if (t["notes"].toString().isNotEmpty)
                                Text("Notes: ${t["notes"]}"),

                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    // DELETE tenant assignment
                                    await db.removeTenantFromRoom(
                                      t["tenant_id"],
                                    );

                                    // Reload UI
                                    await loadOccupants();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${t["name"]} removed from room",
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Remove Tenant",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit-room-building',
                      arguments: room,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Edit Room"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await db.deleteRoom(room!.id!);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete Room"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // INFO ROW WIDGET
  Widget info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$title: $value",
        style: const TextStyle(fontSize: 16, color: Color(0xFF003737)),
      ),
    );
  }
}
