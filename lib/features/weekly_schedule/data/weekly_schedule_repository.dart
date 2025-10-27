import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weekly_schedule_model.dart';

class WeeklyScheduleRepository {
  WeeklyScheduleRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// API: https://lichtuan.dut.udn.vn/api/schedules?email=<email>
  Future<WeeklyScheduleResponse> fetchByEmail(String email) async {
    final uri = Uri.parse(
      'https://lichtuan.dut.udn.vn/api/schedules',
    ).replace(queryParameters: {'email': email});

    final res = await _client.get(
      uri,
      headers: {HttpHeaders.acceptHeader: 'application/json'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        return WeeklyScheduleResponse.fromJson(decoded);
      }
      throw const FormatException('Unexpected response shape');
    }

    throw HttpException('GET $uri failed: ${res.statusCode} ${res.body}');
  }

  void dispose() => _client.close();
}
