import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'token_service.dart';
class StudentService {
  static const String _baseUrl = "http://10.28.237.157:8000/api/students";

  static Future<Map<String, dynamic>> assignHostel({
    required String hostel,
    required String block,
    required String roomNumber,
  }) async {
    final token = await TokenService.getAccessToken();
    if(token == null){
      return{
        "status" : 401,
        "body" : {"error": "User not authenticated"},
      };
    }
    final response = await http.post(
      Uri.parse("$_baseUrl/assign-hostel/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "hostel": hostel,
        "block": block,
        "room_number": roomNumber,
      }),
    ).timeout(const Duration(seconds: 10));

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }
}
