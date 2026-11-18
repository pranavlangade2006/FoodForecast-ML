import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ==========================================
  // 1. TEST BACKEND CONNECTION
  // ==========================================

  static Future<Map<String, dynamic>> testConnection() async {
    final uri = Uri.parse('$baseUrl/test-connection');

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Unexpected response from backend.');
      }

      throw Exception(
        'Connection failed (${response.statusCode}): ${response.body}',
      );
    } on TimeoutException {
      throw Exception('Backend connection timed out.');
    } on http.ClientException catch (e) {
      throw Exception('Cannot connect to FastAPI: $e');
    }
  }

  // ==========================================
  // 2. PREDICT ALL RAW MATERIALS
  // ==========================================

  static Future<Map<String, dynamic>> predictAll({
    required int expectedCustomers,
    required int reservations,
    required int previousDayCustomers,
    required int isWeekend,
    required int isHoliday,
    required int specialEvent,
  }) async {
    final uri = Uri.parse('$baseUrl/predict-all');

    final requestBody = {
      'expected_customers': expectedCustomers,
      'reservations': reservations,
      'previous_day_customers': previousDayCustomers,
      'is_weekend': isWeekend,
      'is_holiday': isHoliday,
      'special_event': specialEvent,
    };

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Unexpected response from prediction API.');
      }

      throw Exception(
        'Prediction API failed (${response.statusCode}): '
        '${response.body}',
      );
    } on TimeoutException {
      throw Exception(
        'Prediction request timed out. Check that FastAPI is running.',
      );
    } on http.ClientException catch (e) {
      throw Exception('Could not connect to FastAPI: $e');
    }
  }
}
