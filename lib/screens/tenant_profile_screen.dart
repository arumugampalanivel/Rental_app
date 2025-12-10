import 'dart:io';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class TenantProfileScreen extends StatefulWidget {
  static const String routeName = '/tenant-profile';

  final int tenantId;
  const TenantProfileScreen({super.key, required this.tenantId});

  @override
  State<TenantProfileScreen> createState() => _TenantProfileScreenState();
}

class _TenantProfileScreenState extends State<TenantProfileScreen> {
  Map<String, dynamic>? tenant;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTenant();
  }

  Future<void> loadTenant() async {
    final db = DBHelper();
    final data = await db.getTenantById(widget.tenantId);

    setState(() {
      tenant = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (tenant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Tenant Profile")),
        body: const Center(child: Text("Tenant not found")),
      );
    }

    final t = tenant!; // safe shortcut

    // Image
    final imagePath = t["photo"]?.toString() ?? "";
    final imageProvider = (imagePath.isNotEmpty && File(imagePath).existsSync())
        ? FileImage(File(imagePath))
        : const AssetImage("assets/user.png") as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenant Profile"),
        backgroundColor: const Color(0xFF008080),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit-personal',
                arguments: {"tenant": t},
              ).then((_) => loadTenant()); // refresh after editing
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final db = DBHelper();
              await db.deleteTenant(widget.tenantId);
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -----------------------------
            // PROFILE PHOTO + NAME
            // -----------------------------
            CircleAvatar(radius: 55, backgroundImage: imageProvider),
            const SizedBox(height: 12),

            Text(
              t["name"] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006666),
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------------
            // RENT SUMMARY CARD
            // -----------------------------
            rentSummaryCard(context, widget.tenantId, t),

            const SizedBox(height: 20),

            // -----------------------------
            // PERSONAL DETAILS
            // -----------------------------
            sectionTitle("Personal Details"),
            infoRow("Mobile", t["mobile"]),
            infoRow("DOB", t["dob"]),
            infoRow("Gender", t["gender"]),
            infoRow("Address", t["address"]),
            infoRow("Occupation", t["occupation"]),
            infoRow("Emergency Contact", t["emergency"]),

            const SizedBox(height: 20),

            // -----------------------------
            // COMPANY DETAILS
            // -----------------------------
            sectionTitle("Company Details"),
            infoRow("Company Name", t["company_name"]),
            infoRow("Location", t["location"]),
            infoRow("Designation", t["designation"]),
            infoRow("Date of Joining", t["date_of_joining"]),

            const SizedBox(height: 20),

            // -----------------------------
            // ROOM DETAILS
            // -----------------------------
            sectionTitle("Room Details"),
            infoRow("Room No", t["room_no"]),
            infoRow("Advance Paid", t["advance"]),
            infoRow("Monthly Rent", t["rent"]),
            infoRow("Rent Date", t["rent_date"]),
            infoRow("Notes", t["notes"]),
          ],
        ),
      ),
    );
  }

  // --------------------------------
  // REUSABLE SECTION TITLE WIDGET
  // --------------------------------
  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF008080),
        ),
      ),
    );
  }

  // --------------------------------
  // REUSABLE INFO ROW
  // --------------------------------
  Widget infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------
  // RENT SUMMARY CARD
  // --------------------------------
  Widget rentSummaryCard(
    BuildContext context,
    int tenantId,
    Map<String, dynamic> tenantMap,
  ) {
    return FutureBuilder(
      future: DBHelper().getLastPaidMonth(tenantId),
      builder: (context, snapshot) {
        String lastPaid = snapshot.data?.toString() ?? "No payments yet";

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rent Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Text(
                  "Last Paid: $lastPaid",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                FutureBuilder(
                  future: DBHelper().getPendingMonths(tenantId),
                  builder: (context, pendSnap) {
                    if (!pendSnap.hasData) return const SizedBox();

                    final pending = pendSnap.data as List<String>;

                    return Text(
                      "Pending: ${pending.length} month(s)",
                      style: TextStyle(
                        fontSize: 16,
                        color: pending.isEmpty ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ADD RENT
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/add-rent',
                          arguments: {
                            "tenantId": tenantId,
                            "tenantName": tenantMap['name'],
                            "roomNo": tenantMap['room_no'],
                          },
                        ).then((_) => setState(() {}));
                      },
                      child: const Text("Add Rent"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                      ),
                    ),

                    // VIEW HISTORY
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/rent-history',
                          arguments: {
                            "tenantId": tenantId,
                            "tenantName": tenantMap['name'],
                            "roomNo": tenantMap['room_no'],
                          },
                        );
                      },
                      child: const Text("View History"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
