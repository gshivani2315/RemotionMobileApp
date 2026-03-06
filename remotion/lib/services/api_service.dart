import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl =
      "http://10.0.2.2:3000"; // Use 10.0.2.2 for Android Emulator

  Future<Map<String, dynamic>?> getProtectedData() async {
    // 1. Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // 2. Force refresh the ID Token
    String? token = await user.getIdToken();

    // 3. Make the request
    final response = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }
}
