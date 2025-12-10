import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  static const routeName = '/summary';

  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final args = ModalRoute.of(context)!.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        body: Center(child: Text("Error: No summary data received!")),
      );
    }

    final personal = data['personal'];
    final company = data['company'];
    final room = data['room'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Summary"),
        backgroundColor: Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Tenant Personal Details"),
            _infoTile("Full Name", personal["name"]),
            _infoTile("Mobile", personal["mobile"]),
            _infoTile("DOB", personal["dob"]),
            _infoTile("Gender", personal["gender"]),
            _infoTile("Address", personal["address"]),
            _infoTile("Occupation", personal["occupation"]),
            _infoTile("Emergency Contact", personal["emergency"]),

            SizedBox(height: 25),

            _sectionTitle("Company / Employer Details"),
            _infoTile("Company Name", company["companyName"]),
            _infoTile("HR Name", company["hrName"]),
            _infoTile("Company Address", company["companyAddress"]),
            _infoTile("Company Contact", company["companyContact"]),
            _infoTile("Company Email", company["companyEmail"]),

            SizedBox(height: 25),

            _sectionTitle("Room & Rent Details"),
            _infoTile("Room No", room["roomNo"]),
            _infoTile("Floor No", room["floorNo"]),
            _infoTile("Advance Amount", room["advance"]),
            _infoTile("Monthly Rent", room["rent"]),
            _infoTile("Move-in Date", room["moveInDate"]),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // FINAL SAVE
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF008080),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Final Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF006666),
        ),
      ),
    );
  }

  Widget _infoTile(String label, dynamic value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text("$value", style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
