import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class EditRoomScreen extends StatefulWidget {
  static const String routeName = '/edit-room';

  const EditRoomScreen({super.key});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final TextEditingController roomNoController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController rentDateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  late Map<String, dynamic> tenant;
  late Map<String, dynamic> updatedPersonal;
  late Map<String, dynamic> updatedCompany;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    tenant = args["tenant"];
    updatedPersonal = args["updatedPersonal"];
    updatedCompany = args["updatedCompany"];

    // Pre-fill room details
    roomNoController.text = tenant["room_no"] ?? "";
    advanceController.text = tenant["advance"] ?? "";
    rentController.text = tenant["rent"] ?? "";
    rentDateController.text = tenant["rent_date"] ?? "";
    notesController.text = tenant["notes"] ?? "";
  }

  Future<void> saveUpdates() async {
    final updatedData = {
      // PERSONAL
      "name": updatedPersonal["name"],
      "photo": updatedPersonal["photo"],
      "mobile": updatedPersonal["mobile"],
      "dob": updatedPersonal["dob"],
      "gender": updatedPersonal["gender"],
      "address": updatedPersonal["address"],
      "occupation": updatedPersonal["occupation"],
      "emergency": updatedPersonal["emergency"],

      // COMPANY
      "company_name": updatedCompany["company_name"],
      "location": updatedCompany["location"],
      "designation": updatedCompany["designation"],
      "date_of_joining": updatedCompany["date_of_joining"],
      "id_card_image": updatedCompany["id_card_image"],

      // ROOM
      "room_no": roomNoController.text,
      "advance": advanceController.text,
      "rent": rentController.text,
      "rent_date": rentDateController.text,
      "notes": notesController.text,
    };

    final db = DBHelper();
    await db.updateTenant(tenant["id"], updatedData);

    // Return to profile screen with updated data
    Navigator.popUntil(context, ModalRoute.withName('/tenant-profile'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Room Details"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomInput(label: "Room Number", controller: roomNoController),
            CustomInput(label: "Advance Paid", controller: advanceController),
            CustomInput(label: "Monthly Rent", controller: rentController),
            CustomInput(
              label: "Rent Paying Date",
              controller: rentDateController,
            ),
            CustomInput(
              label: "Additional Notes",
              controller: notesController,
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveUpdates,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 35,
                ),
              ),
              child: const Text("Save Changes", style: TextStyle(fontSize: 18)),
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
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
