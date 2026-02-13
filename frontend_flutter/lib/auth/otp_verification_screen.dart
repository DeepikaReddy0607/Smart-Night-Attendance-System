import 'dart:async';
import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/auth_service.dart';
import 'auth_guard.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String rollNo;
  final String purpose; // "LOGIN" or "ACTIVATION"

  const OtpVerificationScreen({
    super.key,
    required this.rollNo,
    required this.purpose,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();

  static const int _otpTimeout = 30;
  int _remainingSeconds = _otpTimeout;
  Timer? _timer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = _otpTimeout;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() => _remainingSeconds--);
        }
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      _showError("Enter a valid 6-digit OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.verifyOtp(
        rollNo: widget.rollNo,
        otp: otpController.text.trim(),
        purpose: widget.purpose,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final int status = result["status"];
      final body = result["body"];
      
      print("VERIFY STATUS: ${result["status"]}");
      print("VERIFY BODY: ${result["body"]}");
      if (status == 200) {
        final accessToken = body["access_token"];
        final refreshToken = body["refresh_token"];
        final role = body["role"];

        if (accessToken == null || refreshToken == null) {
          _showError("Invalid server response");
          return;
        }

        await TokenService.saveTokens(
          accessToken: accessToken.toString(),
          refreshToken: refreshToken.toString(),
          role: role?.toString() ?? "student",
        );


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGuard()),
          (route) => false,
        );

        return;
      }

      _showError(body["error"] ?? "Invalid or expired OTP");

    } on TimeoutException {
      _showError("Server not reachable");
    } catch (e) {
      _showError("OTP verification failed");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verify OTP",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Enter the OTP sent to ${widget.rollNo}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "6-digit OTP",
                counterText: "",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("VERIFY & LOGIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
