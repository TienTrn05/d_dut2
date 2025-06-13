import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/signalr_client.dart';

@injectable
class SignalRService {
  late final HubConnection _connection;
  final StreamController<String> _streamController =
      StreamController.broadcast();

  SignalRService()
      : _connection = HubConnectionBuilder()
            .withUrl('https://dangkytinchi.dev.dut.udn.vn/hubs/registration',
                options: HttpConnectionOptions(
                  accessTokenFactory: () async =>
                      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlMjRmMmVjYi1iYjk2LTQ3YjgtOWViMi1mZTE1OTMxYWY0YTgiLCJ1bmlxdWVfbmFtZSI6IjEwMjIxMDIzOUBzdjEuZHV0LnVkbi52biIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlN0dWRlbnQiLCJtc3RlYW10b29sLWFwaS1hY2Nlc3MiOiJUcnVlIiwiZXhwIjoxNzQ3NzU3OTEzfQ.ZXH1Wnr0b2FvLPZvQZS0VPd1lghKvLB5D7rwNkj5qtQ',
                ))
            .build() {
    _connection.start();
  }

  Stream<String> get statusStream => _streamController.stream;

  Future<void> disconnect() async {
    await _connection.stop();
    await _streamController.close();
  }
}
