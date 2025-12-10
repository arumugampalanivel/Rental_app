import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(
        icon: Icons.person_add,
        label: "New Tenant",
        route: "/tenant-registration",
      ),
      _DashboardItem(
        icon: Icons.currency_rupee,
        label: "Rent Update",
        route: "/add-rent",
      ),
      _DashboardItem(icon: Icons.meeting_room, label: "Rooms", route: "/rooms"),
      _DashboardItem(
        icon: Icons.group,
        label: "Tenants List",
        route: "/tenant-list",
      ),
      _DashboardItem(
        icon: Icons.history,
        label: "Payment History",
        route: "/payment-history",
      ),
      _DashboardItem(
        icon: Icons.settings,
        label: "Settings",
        route: "/settings",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF008080),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
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

  _DashboardItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
