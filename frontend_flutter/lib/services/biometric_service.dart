import 'dart:convert';
import 'package:http/http.dart' as http;

class BiometricService {
  static const String baseUrl =
      "http://10.0.2.2:8000/api/biometrics";

  static Future<Map<String, dynamic>> registerBiometric({
    required String rollNo,
    required String biometricType,
    required String biometricTemplate,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roll_no": rollNo,
        "biometric_type": biometricType,
        "biometric_template": biometricTemplate,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }
}
