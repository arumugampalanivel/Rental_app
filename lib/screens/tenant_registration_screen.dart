import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/db_helper.dart';

class TenantRegistrationScreen extends StatefulWidget {
  static const String routeName = '/tenant-registration';

  const TenantRegistrationScreen({super.key});

  @override
  _TenantRegistrationScreenState createState() =>
      _TenantRegistrationScreenState();
}

class _TenantRegistrationScreenState extends State<TenantRegistrationScreen> {
  Future<void> saveTenantData() async {
    final db = DBHelper();

    Map<String, dynamic> tenantData = {
      "name": nameController.text,
      "photo": pickedImage != null ? pickedImage!.path : "",
      "mobile": mobileController.text,
      "dob": dobController.text,
      "gender": genderController.text,
      "address": addressController.text,
      "occupation": occupationController.text,
      "emergency": emergencyController.text,
    };

    int tenantId = await db.insertTenant(tenantData);

    Navigator.pushNamed(
      context,
      '/company-details',
      arguments: {"tenant_id": tenantId},
    );
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();

  File? pickedImage;

  Future pickImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() => pickedImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Tenant Registration"),
        backgroundColor: Color(0xFF008080),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Photo
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: pickedImage != null
                      ? FileImage(pickedImage!)
                      : null,
                  child: pickedImage == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.teal.shade700,
                        )
                      : null,
                ),
              ),
            ),

            SizedBox(height: 20),

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

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await saveTenantData();
                  // Go to next section → company details
                  //Navigator.pushNamed(context, '/company-details');
                  Navigator.pushNamed(
                    context,
                    '/company-details',
                    arguments: {
                      "personal": {
                        "name": nameController.text,
                        "mobile": mobileController.text,
                        "dob": dobController.text,
                        "gender": genderController.text,
                        "address": addressController.text,
                        "occupation": occupationController.text,
                        "emergency": emergencyController.text,
                        "photo": pickedImage?.path ?? "",
                      },
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF008080),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Input Widget
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
            borderSide: BorderSide(color: Color(0xFF008080), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
