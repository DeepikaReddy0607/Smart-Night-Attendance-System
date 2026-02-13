import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../student/student_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../services/token_service.dart';
import 'auth_guard.dart';
import 'activate_account.dart';
import 'otp_verification_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  Future<void> _handleLogin() async {
  final identifier = identifierController.text.trim();
  final password = passwordController.text.trim();

  if (identifier.isEmpty || password.isEmpty) {
    _showError("All fields are required");
    return;
  }

  setState(() => isLoading = true);

  final result = await AuthService.login(
    rollNo: identifier,
    password: password,
  );

  setState(() => isLoading = false);

  if (result["status"] == 200) {
    // Password correct → OTP sent
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          rollNo: identifier,
          purpose: "LOGIN",
        ),
      ),
    );
  } else {
    _showError(result["body"]?["error"] ?? "Authentication failed");
  }
}
  

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/noctra_logo.png",
              height: 90,
            ),

            const SizedBox(height: 32),

            const Text(
              "Secure Login",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Authorized users only",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: identifierController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Roll Number / Mobile",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: const TextStyle(color: Colors.grey),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("LOGIN"),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ActivateAccountScreen(),
                  ),
                );
              },
              child: const Text("New user? Activate account here"),
            ),
          ],
        ),
      ),
    );
  }
}
