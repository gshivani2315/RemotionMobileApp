// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';

// class ApiService {
//   static const String baseUrl =
//       "http://10.0.2.2:3000"; // Use 10.0.2.2 for Android Emulator

//   Future<Map<String, dynamic>?> getProtectedData() async {
//     // 1. Get the current user
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) return null;

//     // 2. Force refresh the ID Token
//     String? token = await user.getIdToken();

//     // 3. Make the request
//     final response = await http.get(
//       Uri.parse('$baseUrl/api/profile'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       print("Error: ${response.statusCode}");
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3001',
  );

  Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    // CHANGED: forceRefresh: true — never use a stale token
    return await user.getIdToken(true);
  }

  Future<Map<String, dynamic>?> getProtectedData() async {
    final token = await _getAuthToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10)); // ADDED: never hang forever

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // CHANGED: no print in production — don't log status codes or responses
        return null;
      }
    } catch (e) {
      // CHANGED: catches timeout, no network, etc. instead of crashing
      return null;
    }
  }

  // ADDED: dashboard stats endpoint
  Future<Map<String, dynamic>?> getDashboardStats() async {
    final token = await _getAuthToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/dashboard/stats'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
