import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'hostel_details_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String rollNo;

  const OtpVerificationScreen({
    super.key,
    required this.rollNo,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
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
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      _showError("Enter a valid 6-digit OTP");
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.verifyOtp(
      rollNo: widget.rollNo,
      otp: otpController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result["status"] == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HostelDetailsScreen(rollNo: widget.rollNo),
        ),
      );
    } else {
      _showError(
        result["body"]["error"] ?? "OTP verification failed",
      );
    }
  }

  void _showError(String message) {
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

            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  "Resend OTP in ",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  _remainingSeconds > 0
                      ? "${_remainingSeconds}s"
                      : "now",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: _remainingSeconds == 0 && !isLoading
                  ? () {
                      _startTimer();
                      _showError("Resend OTP not enabled yet");
                    }
                  : null,
              child: const Text("RESEND OTP"),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("VERIFY & PROCEED"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
