import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'package:intl/intl.dart';

class AddRentScreen extends StatefulWidget {
  static const routeName = '/add-rent';

  final int tenantId;

  const AddRentScreen({super.key, required this.tenantId});

  @override
  State<AddRentScreen> createState() => _AddRentScreenState();
}

class _AddRentScreenState extends State<AddRentScreen> {
  final TextEditingController monthController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paidDateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedStatus = "Paid";

  @override
  void initState() {
    super.initState();

    // Set default month
    String defaultMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    monthController.text = defaultMonth;

    // Paid date defaults to today
    paidDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  Future<void> saveRent() async {
    final data = {
      "tenant_id": widget.tenantId,
      "month": monthController.text,
      "amount": amountController.text,
      "paid_date": paidDateController.text,
      "status": selectedStatus,
      "note": noteController.text,
    };

    await DBHelper().insertRent(data);
    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Rent Payment"),
        backgroundColor: Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomInput(label: "Month", controller: monthController),
            CustomInput(label: "Amount", controller: amountController),
            CustomInput(label: "Paid Date", controller: paidDateController),
            CustomInput(
              label: "Notes",
              controller: noteController,
              maxLines: 2,
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField(
              initialValue: selectedStatus,
              decoration: InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ["Paid", "Pending", "Partial"].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (v) {
                setState(() => selectedStatus = v!);
              },
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: saveRent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF008080),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 40,
                ),
              ),
              child: const Text("Save Rent", style: TextStyle(fontSize: 18)),
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

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
