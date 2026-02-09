import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import 'login_screen.dart';

class BiometricRegisterScreen extends StatefulWidget {
  final String rollNo;

  const BiometricRegisterScreen({
    super.key,
    required this.rollNo,
  });

  @override
  State<BiometricRegisterScreen> createState() =>
      _BiometricRegisterScreenState();
}

class _BiometricRegisterScreenState extends State<BiometricRegisterScreen> {
  bool isLoading = false;

  Future<void> _registerBiometric() async {
    setState(() => isLoading = true);

    try {
      // 🔹 MOCK biometric data (no camera yet)
      const String mockBiometricTemplate = "mock_face_data_base64";

      final result = await BiometricService.registerBiometric(
        rollNo: widget.rollNo,
        biometricType: "FACE",
        biometricTemplate: mockBiometricTemplate,
      );

      if (result["status"] == 201) {
        // 🔥 Registration COMPLETE → force login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      } else {
        _showError(
          result["body"]["error"] ?? "Biometric registration failed",
        );
      }
    } catch (e) {
      _showError("Network error. Please try again.");
      debugPrint("BIOMETRIC ERROR: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biometric Registration"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Register Biometric",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            const Text(
              "Biometric verification is mandatory to complete registration.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.fingerprint, size: 64),
                  SizedBox(height: 16),
                  Text(
                    "Mock biometric capture",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Camera integration will be added later",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _registerBiometric,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("REGISTER BIOMETRIC"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
