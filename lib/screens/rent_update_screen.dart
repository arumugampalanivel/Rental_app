import 'package:flutter/material.dart';

class RentUpdateScreen extends StatefulWidget {
  static const String routeName = '/rent-update';

  const RentUpdateScreen({super.key});

  @override
  _RentUpdateScreenState createState() => _RentUpdateScreenState();
}

class _RentUpdateScreenState extends State<RentUpdateScreen> {
  String? selectedTenant;
  String? selectedMonth;
  String? selectedStatus;

  final TextEditingController rentAmountController = TextEditingController();
  final TextEditingController paidDateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final List<String> tenantList = [
    "Arun",
    "Prakash",
    "Lakshmi",
    "Vijay",
    "Kumar",
  ];

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final List<String> paymentStatus = ["Paid", "Pending"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rent Update"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Tenant Dropdown
            DropdownInput(
              label: "Select Tenant",
              value: selectedTenant,
              items: tenantList,
              onChanged: (value) {
                setState(() {
                  selectedTenant = value;
                });
              },
            ),

            // Select Month Dropdown
            DropdownInput(
              label: "Select Month",
              value: selectedMonth,
              items: months,
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
            ),

            CustomInput(
              label: "Rent Amount",
              controller: rentAmountController,
              keyboardType: TextInputType.number,
            ),

            CustomInput(
              label: "Paid Date",
              controller: paidDateController,
              keyboardType: TextInputType.datetime,
            ),

            DropdownInput(
              label: "Payment Status",
              value: selectedStatus,
              items: paymentStatus,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),

            CustomInput(
              label: "Notes (optional)",
              controller: notesController,
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                ),

                // Update Button
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Rent updated successfully!"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008080),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class DropdownInput extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const DropdownInput({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
