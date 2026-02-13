import 'dart:async';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'otp_verification_screen.dart';

class ActivateAccountScreen extends StatefulWidget {
  const ActivateAccountScreen({super.key});

  @override
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen> {
  final TextEditingController rollController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _sendOtp() async {
    if (rollController.text.isEmpty || passwordController.text.isEmpty) {
      _showError("All fields are required");
      return;
    }

    print("UI → SEND OTP CLICKED");

    setState(() => isLoading = true);

    try {
      print("UI → Calling AuthService.sendOtp");

      final result = await AuthService.sendOtp(
        rollNo: rollController.text.trim(),
        password: passwordController.text.trim(),
      ).timeout(const Duration(seconds: 10));

      print("UI → SEND OTP RESPONSE: $result");

      if (!mounted) return;

      if (result["status"] == 200 || result["status"] == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              rollNo: rollController.text.trim(),
              purpose: "ACTIVATION",
            ),
          ),
        );
      } else {
        _showError(result["body"]?["error"] ?? "Failed to send OTP");
      }
    } on TimeoutException {
      print("UI → SEND OTP TIMEOUT");
      _showError("Server not reachable. Check network.");
    } catch (e) {
      print("UI → SEND OTP ERROR: $e");
      _showError("Error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activate Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Account Activation",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: rollController,
              decoration: const InputDecoration(
                labelText: "Roll Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendOtp,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("SEND OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}