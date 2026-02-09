import 'package:flutter/material.dart';

class ConfirmDetailsScreen extends StatelessWidget {
  final String fullName;
  final String branch;
  final String year;
  final String gender;
  final String college;

  const ConfirmDetailsScreen({
    super.key,
    required this.fullName,
    required this.branch,
    required this.year,
    required this.gender,
    required this.college,
  });

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Details"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verify your details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            const Text(
              "Fetched from official records",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            _infoCard("Full Name", fullName),
            _infoCard("Branch & Year", "$branch • $year"),
            _infoCard("Gender", gender),
            _infoCard("College", college),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Hostel Details Screen
                },
                child: const Text("CONTINUE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
