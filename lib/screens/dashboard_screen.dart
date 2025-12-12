import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final db = DBHelper();

  int totalTenants = 0;
  int pendingTenants = 0;
  double monthlyCollected = 0.0;
  int totalRooms = 0;
  int occupiedRooms = 0;
  int vacantRooms = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    totalTenants = await db.getTotalTenantCount();
    pendingTenants = await db.getPendingTenantCount();
    monthlyCollected = await db.getMonthlyCollectedAmount();

    // Rooms
    final rooms = await db.getAllRooms();
    totalRooms = rooms.length;

    int occ = 0;
    final database = await db.database;

    for (var r in rooms) {
      final result = await database.rawQuery(
        "SELECT COUNT(*) AS count FROM room WHERE room_no = ?",
        [r.roomNo],
      );
      if ((result.first["count"] as int) > 0) {
        occ++;
      }
    }

    occupiedRooms = occ;
    vacantRooms = totalRooms - occupiedRooms;

    setState(() {});
  }

  // Modern statistic card
  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color,
              child: Icon(icon, size: 26, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(Icons.person_add, "New Tenant", "/tenant-registration"),
      _DashboardItem(Icons.currency_rupee, "Rent Update", "/rent-update-flow"),
      _DashboardItem(Icons.meeting_room, "Rooms", "/rooms"),
      _DashboardItem(Icons.group, "Tenants List", "/tenant-list"),
      _DashboardItem(Icons.history, "Payment History", "/payment-history"),
      _DashboardItem(Icons.settings, "Settings", "/settings"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF008080),
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ----------- Modern Stats Section -------------
              Row(
                children: [
                  statCard(
                    "Tenants",
                    "$totalTenants",
                    Icons.people,
                    Colors.blue,
                  ),
                  statCard(
                    "Pending",
                    "$pendingTenants",
                    Icons.warning,
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  statCard(
                    "Collected",
                    "₹$monthlyCollected",
                    Icons.currency_rupee,
                    Colors.green,
                  ),
                  statCard(
                    "Rooms",
                    "$occupiedRooms/$totalRooms",
                    Icons.meeting_room,
                    Colors.teal,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ------------ EXISTING GRID MENU (UNCHANGED) -------------
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  return dashboardCard(context, items[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context, _DashboardItem item) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 48, color: const Color(0xFF008080)),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF004D4D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final IconData icon;
  final String label;
  final String route;

  _DashboardItem(this.icon, this.label, this.route);
}
