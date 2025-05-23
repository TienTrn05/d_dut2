import '../../data/data_sourses/stream_data_source/signalr_service.dart';

class RegistrationSignalRRepository {
  final SignalRService _signalRService;

  RegistrationSignalRRepository(this._signalRService);

  Stream<String> response() {
    return _signalRService.statusStream;
  }

  Future<void> initConnection() async {
    await _signalRService.connect();
  }
}