import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CompanyDetailsScreen extends StatefulWidget {
  static const String routeName = '/company-details';

  const CompanyDetailsScreen({super.key});

  @override
  _CompanyDetailsScreenState createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController dojController = TextEditingController();

  File? idCardImage;

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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final personalData = args["personal"];

    return Scaffold(
      appBar: AppBar(
        title: Text("Company Details"),
        backgroundColor: Color(0xFF008080),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            CustomInput(label: "Date of Joining", controller: dojController),

            SizedBox(height: 20),

            Text(
              "Upload ID Card",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),

            GestureDetector(
              onTap: pickIDCard,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal, width: 1),
                ),
                child: idCardImage == null
                    ? Center(
                        child: Icon(
                          Icons.upload_file,
                          size: 40,
                          color: Colors.teal,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(idCardImage!, fit: BoxFit.cover),
                      ),
              ),
            ),

            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit Button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Edit"),
                ),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/room-details',
                      arguments: {
                        "personal": personalData,
                        "company": {
                          "company_name": companyNameController.text,
                          "designation": designationController.text,
                          "DoJ": dojController.text,
                        },
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF008080),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                ),

                // Cancel Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable input widget
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
