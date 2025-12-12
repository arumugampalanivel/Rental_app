import 'package:flutter/material.dart';

class RoomDetailsScreen extends StatefulWidget {
  static const String routeName = "/room-details-building";

  const RoomDetailsScreen({super.key});

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

//final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final TextEditingController roomNoController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController rentDateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final personalData = args["personal"];
    final companyData = args["company"];
    return Scaffold(
      appBar: AppBar(
        title: Text("Room Details"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit Button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Edit"),
                ),

                // Save Button → Move to Summary Screen
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/summary',
                      arguments: {
                        "personal": personalData,
                        "company": companyData,
                        "room": {
                          "room_no": roomNoController.text,
                          "advance": advanceController.text,
                          "rent": rentController.text,
                        },
                      },
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
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

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
