import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/api/auth";

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String rollNo,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "roll_no": rollNo,
        "password": password,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // SEND OTP
  static Future<Map<String, dynamic>> sendOtp({
    required String rollNo,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/send-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "roll_no": rollNo,
        "password": password,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  // VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String rollNo,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/verify-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "roll_no": rollNo,
        "otp": otp,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }
}
