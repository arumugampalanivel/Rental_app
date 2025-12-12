import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/room_model.dart';
import 'room_details_building_screen.dart';
import 'edit_room_building_screen.dart';

class RoomsScreen extends StatefulWidget {
  static const routeName = '/rooms';

  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<RoomModel> rooms = [];
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    final data = await db.getAllRooms();
    setState(() {
      rooms = data;
    });
  }

  /// Count how many tenants are assigned to this room
  Future<int> getOccupancy(RoomModel room) async {
    final database = await db.database;

    final result = await database.rawQuery(
      "SELECT COUNT(*) AS count FROM room WHERE room_no = ?",
      [room.roomNo],
    );

    return result.first["count"] as int;
  }

  Future<void> deleteRoom(int id) async {
    await db.deleteRoom(id);
    loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
        backgroundColor: const Color(0xFF008080),
      ),

      // ✅ FIXED — Opens AddRoomScreen instead of crashing
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? refresh = await Navigator.pushNamed(context, '/add-room');
          if (refresh == true) loadRooms();
        },
        backgroundColor: const Color(0xFF008080),
        child: const Icon(Icons.add),
      ),

      body: rooms.isEmpty
          ? const Center(child: Text("No rooms added yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];

                return FutureBuilder(
                  future: getOccupancy(room),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final current = snapshot.data as int;
                    final max = room.maxOccupants;

                    // Room status logic
                    String finalStatus = room.status;
                    if (current >= max) finalStatus = "Occupied";

                    Color statusColor = finalStatus == "Available"
                        ? Colors.green
                        : Colors.red;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ROOM TITLE
                            Text(
                              "Room ${room.roomNo}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004D4D),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // FLOOR + LOCATION
                            Text(
                              "Floor: ${room.floor}   |   Location: ${room.location}",
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),

                            // RENT
                            Text(
                              "Rent: ₹${room.rent}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // OCCUPANCY
                            Text(
                              "Occupancy: $current / $max",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // STATUS
                            Text(
                              "Status: $finalStatus",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // BUTTON ROW (View | Edit | Delete)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 🔵 VIEW DETAILS
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      RoomDetailsBuildingScreen.routeName,
                                      arguments: room,
                                    ).then((_) => loadRooms());
                                  },
                                  child: const Text("View"),
                                ),

                                // 🟠 EDIT ROOM
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      EditRoomBuildingScreen.routeName,
                                      arguments: room,
                                    ).then((_) => loadRooms());
                                  },
                                  child: const Text("Edit"),
                                ),

                                // 🔴 DELETE ROOM
                                TextButton(
                                  onPressed: () => deleteRoom(room.id!),
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
                );
              },
            ),
    );
  }
}
