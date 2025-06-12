import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  bool get isServerConnected => _serverStatus == ServerStatus.online;
  IO.Socket get socket => _socket;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    _socket = IO.io('http://localhost:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _socket.on('emit-message', (payload) {
      print('Name:' + payload['name']);
      print('Message:' + payload['message']);
    });
  }
}
