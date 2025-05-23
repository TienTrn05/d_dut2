import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/signalr_client.dart';

@injectable
class SignalRService {
  late HubConnection _connection;
  final StreamController<String> _streamController =
      StreamController.broadcast();

  SignalRService();

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
        .withUrl('https://192.168.1.4:7017/hubs/registration',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlMjRmMmVjYi1iYjk2LTQ3YjgtOWViMi1mZTE1OTMxYWY0YTgiLCJ1bmlxdWVfbmFtZSI6IjEwMjIxMDIzOUBzdjEuZHV0LnVkbi52biIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlN0dWRlbnQiLCJtc3RlYW10b29sLWFwaS1hY2Nlc3MiOiJUcnVlIiwiZXhwIjoxNzQ3NzU3OTEzfQ.ZXH1Wnr0b2FvLPZvQZS0VPd1lghKvLB5D7rwNkj5qtQ',
            ))
        .build();

    _connection.on('ReceiveRegistrationStatus', (args) {
      final courseId = args?[0] as String;
      final status = args?[1] as String;
      _streamController.add('Received status for course $courseId: $status');
    });

    await _connection.start();
  }

  Stream<String> get statusStream => _streamController.stream;

  Future<void> disconnect() async {
    await _connection.stop();
  }
}
