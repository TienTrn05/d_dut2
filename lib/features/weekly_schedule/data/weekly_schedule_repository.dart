import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/weekly_schedule_model.dart';

class WeeklyScheduleRepository {
  WeeklyScheduleRepository({http.Client? client, String? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? _resolveWeeklyApiBase();

  final http.Client _client;
  final String _endpoint;

  Future<WeeklyScheduleResponse> fetchByEmail(
    String email, {
    DateTime? date,
  }) async {
    if (_endpoint.trim().isEmpty) {
      throw StateError(
        'Weekly schedule API base is empty. '
        'Set WEEKLY_SCHEDULE_API_BASE in .env or via --dart-define.',
      );
    }

    final Map<String, String> queryParameters = {'email': email};

    if (date != null) {
      queryParameters['date'] = _formatDateAsYyyyMmDd(date);
    }

    final uri = Uri.parse(_endpoint).replace(queryParameters: queryParameters);

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

String _resolveWeeklyApiBase() {
  const fromDefine = String.fromEnvironment(
    'WEEKLY_SCHEDULE_API_BASE',
    defaultValue: '',
  );
  if (fromDefine.isNotEmpty) return fromDefine;

  try {
    return dotenv.env['WEEKLY_SCHEDULE_API_BASE'] ?? '';
  } catch (_) {
    return '';
  }
}
String _formatDateAsYyyyMmDd(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
