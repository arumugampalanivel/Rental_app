import 'dart:io';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'tenant_profile_screen.dart';

class TenantListScreen extends StatefulWidget {
  const TenantListScreen({super.key});

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  List<Map<String, dynamic>> tenants = [];

  @override
  void initState() {
    super.initState();
    loadTenants();
  }

  Future<void> loadTenants() async {
    final data = await DBHelper().getAllTenants();
    setState(() {
      tenants = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenant List"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: tenants.isEmpty
          ? const Center(child: Text("No tenants added yet"))
          : ListView.builder(
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final t = tenants[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TenantProfileScreen(tenantId: t['id']),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              t['photo'] != null &&
                                  t['photo'].toString().trim().isNotEmpty
                              ? FileImage(File(t['photo']))
                              : const AssetImage("assets/user.png")
                                    as ImageProvider,
                        ),
                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Room No
                              Text("Room: ${t['room_no'] ?? '-'}"),

                              // Mobile
                              Text("Mobile: ${t['mobile'] ?? '-'}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF008080),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/tenant-registration');
        },
      ),
    );
  }
}
