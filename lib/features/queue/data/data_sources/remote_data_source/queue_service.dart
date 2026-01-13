import 'package:dio/dio.dart';
import 'package:e_dut/common/utils/app_environment.dart';
import 'package:e_dut/common/utils/logger.dart';
import 'package:e_dut/core/services/api_client.dart';
import 'package:e_dut/features/queue/data/models/counter_queue_model.dart';
import 'package:e_dut/features/queue/data/models/user_ticket_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class QueueService {
  final String _url;
  final ApiClient _apiClient;

  QueueService(@Named('queueAPIUrl') String url)
    : _url = url,
      _apiClient = ApiClient(url);

  Future<List<CounterQueueModel>> getAllQueueCounter() async {
    try {
      final response = await _apiClient.dio.get(
        '$_url/api/Ticket/GetAllQueueTicket',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': AppEnvironment.queueAPIKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        final List<CounterQueueModel> counters =
            data.map((item) => CounterQueueModel.fromJson(item)).toList();

        counters.sort((a, b) => a.noCounter.compareTo(b.noCounter));

        return counters;
      } else {
        throw Exception(
          "Fail to load all queue counter: ${response.data['message']}",
        );
      }
    } catch (e) {
      if (e is DioException) {
        logger.e("Request URL: ${e.requestOptions.uri}");
      }
      logger.e("Fail to load all queue counter: $e");
      throw Exception("Fail to load all queue counter: $e");
    }
  }

  Future<List<UserTicketModel>> getUserTicketsToday(String noGuest) async {
    try {
      final response = await _apiClient.dio.get(
        '$_url/api/Ticket/TrackingMyTicketsToday',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': AppEnvironment.queueAPIKey,
          },
        ),
        queryParameters: {'noGuest': noGuest},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final List<dynamic> data = responseData['data'];

        final List<UserTicketModel> counters =
            data.map((item) => UserTicketModel.fromJson(item)).toList();

        counters.sort((a, b) => a.noCounter.compareTo(b.noCounter));

        return counters;
      } else {
        throw Exception(
          "Fail to load user tickets: ${response.data['message']}",
        );
      }
    } catch (e) {
      logger.e("Fail to load user tickets: $e");
      throw Exception("Fail to load user tickets: $e");
    }
  }
}
