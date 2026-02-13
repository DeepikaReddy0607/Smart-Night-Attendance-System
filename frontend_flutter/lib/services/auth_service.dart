import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 🔴 Replace with your laptop IP + port
  static const String baseUrl = "http://10.28.237.157:8000/api/auth";

  // =========================
  // LOGIN (Password Only)
  // =========================
  static Future<Map<String, dynamic>> login({
    required String rollNo,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/login/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "roll_no": rollNo,
            "password": password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // =========================
  // SEND OTP (Activation / Login OTP)
  // =========================
  static Future<Map<String, dynamic>> sendOtp({
    required String rollNo,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/send-otp/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "roll_no": rollNo,
            "password": password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }


// =========================
// VERIFY OTP
// =========================
static Future<Map<String, dynamic>> verifyOtp({
  required String rollNo,
  required String otp,
  required String purpose,
}) async {
  final response = await http
      .post(
        Uri.parse("$baseUrl/verify-otp/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roll_no": rollNo,
          "otp": otp,
          "purpose": purpose,
        }),
      )
      .timeout(const Duration(seconds: 10));

  return {
    "status": response.statusCode,
    "body": jsonDecode(response.body),
  };
}
}
