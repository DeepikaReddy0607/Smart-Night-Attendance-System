import 'package:flutter/material.dart';

class VerifyStudentScreen extends StatefulWidget {
  const VerifyStudentScreen({super.key});

  @override
  State<VerifyStudentScreen> createState() => _VerifyStudentScreenState();
}

class _VerifyStudentScreenState extends State<VerifyStudentScreen> {
  final TextEditingController _regNoController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _verifyStudent() async {
    if (_regNoController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: Call verify-student API here
    await Future.delayed(const Duration(seconds: 2));

    // TEMP MOCK RESPONSE
    final bool studentFound = true;

    setState(() {
      _isLoading = false;
    });

    if (!studentFound) {
      setState(() {
        _error = "Registration number not found";
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ConfirmDetailsScreen(
            fullName: "Ravi Kumar",
            branch: "CSE",
            year: "2nd Year",
            gender: "Male",
            college: "ABC Engineering College",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            Center(
              child: Image.asset(
                "assets/images/noctra_logo.png",
                height: 80,
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Student Verification",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            const Text(
              "Enter your registration number",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _regNoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Registration Number",
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyStudent,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("VERIFY"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
