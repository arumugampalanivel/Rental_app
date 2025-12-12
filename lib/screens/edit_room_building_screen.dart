import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/room_model.dart';

class EditRoomBuildingScreen extends StatefulWidget {
  static const String routeName = '/edit-room-building';

  const EditRoomBuildingScreen({super.key});

  @override
  State<EditRoomBuildingScreen> createState() => _EditRoomBuildingScreenState();
}

class _EditRoomBuildingScreenState extends State<EditRoomBuildingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController roomNoController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController maxOccupantsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedStatus = "Available";

  RoomModel? room;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    room = ModalRoute.of(context)!.settings.arguments as RoomModel;

    // Pre-fill values
    roomNoController.text = room!.roomNo;
    floorController.text = room!.floor;
    locationController.text = room!.location;
    advanceController.text = room!.advance.toString();
    rentController.text = room!.rent;
    maxOccupantsController.text = room!.maxOccupants.toString();
    notesController.text = room!.notes;
    selectedStatus = room!.status;
  }

  Future<void> updateRoom() async {
    final data = {
      "room_no": roomNoController.text,
      "floor": floorController.text,
      "location": locationController.text,
      "advance": double.tryParse(advanceController.text) ?? 0.0,
      "rent": rentController.text,
      "max_occupants": int.tryParse(maxOccupantsController.text) ?? 0,
      "notes": notesController.text,
      "status": selectedStatus,
    };

    await DBHelper().updateRoom(room!.id!, data);

    Navigator.pop(context, true); // return and refresh rooms list
  }

  @override
  Widget build(BuildContext context) {
    if (room == null) return SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Room"),
        backgroundColor: const Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(label: "Room Number", controller: roomNoController),
              CustomInput(label: "Floor", controller: floorController),
              CustomInput(
                label: "Location / Block",
                controller: locationController,
              ),
              CustomInput(
                label: "Advance Amount",
                controller: advanceController,
                isNumber: true,
              ),
              CustomInput(label: "Monthly Rent", controller: rentController),
              CustomInput(
                label: "Maximum Occupants",
                controller: maxOccupantsController,
                isNumber: true,
              ),
              CustomInput(
                label: "Notes",
                controller: notesController,
                maxLines: 3,
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField(
                initialValue: selectedStatus,
                decoration: InputDecoration(
                  labelText: "Room Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ["Available", "Occupied"].map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateRoom();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 30,
                  ),
                ),
                child: const Text(
                  "Update Room",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumber;
  final int maxLines;

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    this.isNumber = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }
          if (isNumber && double.tryParse(value) == null) {
            return "Enter a valid number";
          }
          return null;
        },
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
