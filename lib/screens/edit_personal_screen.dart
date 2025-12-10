import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPersonalScreen extends StatefulWidget {
  static const String routeName = '/edit-personal';

  const EditPersonalScreen({super.key});

  @override
  State<EditPersonalScreen> createState() => _EditPersonalScreenState();
}

class _EditPersonalScreenState extends State<EditPersonalScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();

  File? pickedImage;
  late Map<String, dynamic> tenant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    tenant = args["tenant"];

    // Pre-fill data
    nameController.text = tenant["name"] ?? "";
    mobileController.text = tenant["mobile"] ?? "";
    dobController.text = tenant["dob"] ?? "";
    genderController.text = tenant["gender"] ?? "";
    addressController.text = tenant["address"] ?? "";
    occupationController.text = tenant["occupation"] ?? "";
    emergencyController.text = tenant["emergency"] ?? "";

    if (tenant["photo"] != null && tenant["photo"].toString().isNotEmpty) {
      pickedImage = File(tenant["photo"]);
    }
  }

  Future pickNewImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Personal Details"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickNewImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal.shade100,
                backgroundImage: pickedImage != null
                    ? FileImage(pickedImage!)
                    : const AssetImage("assets/user.png") as ImageProvider,
              ),
            ),

            const SizedBox(height: 20),
            CustomInput(label: "Full Name", controller: nameController),
            CustomInput(label: "Mobile Number", controller: mobileController),
            CustomInput(label: "Date of Birth", controller: dobController),
            CustomInput(label: "Gender", controller: genderController),
            CustomInput(
              label: "Present Address",
              controller: addressController,
            ),
            CustomInput(label: "Occupation", controller: occupationController),
            CustomInput(
              label: "Emergency Contact",
              controller: emergencyController,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Go to company edit screen
                Navigator.pushNamed(
                  context,
                  '/edit-company',
                  arguments: {
                    "tenant": tenant,
                    "updatedPersonal": {
                      "name": nameController.text,
                      "mobile": mobileController.text,
                      "dob": dobController.text,
                      "gender": genderController.text,
                      "address": addressController.text,
                      "occupation": occupationController.text,
                      "emergency": emergencyController.text,
                      "photo": pickedImage?.path ?? tenant["photo"],
                    },
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 25,
                ),
              ),
              child: const Text("Next"),
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

  const CustomInput({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
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
