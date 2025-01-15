import 'dart:convert';
import 'dart:io';
import 'package:window_manager/window_manager.dart';

void startServer(int port) async {
  final server = await ServerSocket.bind('127.0.0.1', port);
  // print('Listening on ${server.address}:${server.port}');
  server.listen((Socket socket) {
    socket.listen((data) async {
      // print('Received: ${String.fromCharCodes(data)}');
      switch (String.fromCharCodes(data)) {
        case 'show':
          await windowManager.show();
          socket.write('success');
          break;
        case 'exit':
          socket.write('success');
          exit(0);
        case 'isrunning':
          socket.write('running');
          break;
        default:
          socket.write('unknown instruction');
          break;
      }
      await socket.flush();
      socket.destroy();
    });
  });
}

Future<String> sendMessage(String message, int port) async {
  final socket = await Socket.connect('127.0.0.1', port);
  socket.write(message);
  await socket.flush();
  String response = await socket.map(utf8.decode).join();
  socket.destroy();
  return response;
}

Future<bool> isPortInUse(int port) async {
  try {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    await server.close();
    return false;
  } catch (e) {
    return true;
  }
}