import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditCompanyScreen extends StatefulWidget {
  static const String routeName = '/edit-company';

  const EditCompanyScreen({super.key});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController joiningDateController = TextEditingController();

  File? idCardImage;

  late Map<String, dynamic> tenant;
  late Map<String, dynamic> updatedPersonal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    tenant = args["tenant"];
    updatedPersonal = args["updatedPersonal"];

    // Set existing values
    companyNameController.text = tenant["company_name"] ?? "";
    locationController.text = tenant["location"] ?? "";
    designationController.text = tenant["designation"] ?? "";
    joiningDateController.text = tenant["date_of_joining"] ?? "";

    if (tenant["id_card_image"] != null &&
        tenant["id_card_image"].toString().isNotEmpty) {
      idCardImage = File(tenant["id_card_image"]);
    }
  }

  Future pickIDCard() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() => idCardImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Company Details"),
        backgroundColor: const Color(0xFF008080),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomInput(
              label: "Company Name",
              controller: companyNameController,
            ),
            CustomInput(label: "Location", controller: locationController),
            CustomInput(
              label: "Designation",
              controller: designationController,
            ),
            CustomInput(
              label: "Date of Joining",
              controller: joiningDateController,
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickIDCard,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, color: Colors.teal),
                    const SizedBox(width: 10),
                    Text(
                      idCardImage == null
                          ? "Upload ID Card"
                          : "ID Card Selected",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-room',
                  arguments: {
                    "tenant": tenant,
                    "updatedPersonal": updatedPersonal,
                    "updatedCompany": {
                      "company_name": companyNameController.text,
                      "location": locationController.text,
                      "designation": designationController.text,
                      "date_of_joining": joiningDateController.text,
                      "id_card_image":
                          idCardImage?.path ?? tenant["id_card_image"],
                    },
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
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
