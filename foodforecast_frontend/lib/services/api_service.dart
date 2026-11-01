import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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

        throw Exception('Unexpected response from the API.');
      }

      throw Exception(
        'API request failed (${response.statusCode}): '
        '${response.body}',
      );
    } on TimeoutException {
      throw Exception(
        'The API request timed out. Check that FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception(
        'Could not connect to FastAPI. Check the server and CORS settings. '
        '$error',
      );
    }
  }
}
