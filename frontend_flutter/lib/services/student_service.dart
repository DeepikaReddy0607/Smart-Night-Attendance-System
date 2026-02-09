import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class StudentService {
  static const String _baseUrl = "http://10.0.2.2:8000/api/students";

  static Future<Map<String, dynamic>> assignHostel({
    required String rollNo,
    required String hostel,
    required String block,
    required String roomNumber,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/assign-hostel/"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roll_no": rollNo,
        "hostel": hostel,
        "block": block,
        "room_number": roomNumber,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }
}
