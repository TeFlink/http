import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

class Server {
  Server({int port = 8000}) {
    server = TeFlinkHttp(port: port);
  }

  TeFlinkHttp server;

  void addRoute(dynamic controller) {
    server.addRoute(controller);
  }

  void entryPoint() {
    server.serve();
  }
}

class TeFlinkHttp {
  TeFlinkHttp({this.port});

  int port;
  dynamic handler;
  List<dynamic> controllers = [];

  void addRoute(dynamic controller) {
    controllers.add(controller);
  }

  void serve() async {
    handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler((request) => _echoRequest(request));
    var server = await io.serve(handler, _hostname, port);
    print('Serving at http://${server.address.host}:${server.port}');
  }

  shelf.Response _echoRequest(shelf.Request request) {
    final controller = controllers.where((c) =>
        c['method'].toString() == request.method &&
        c['route'].toString() == request.url.path);
    print(controller);
    return shelf.Response.ok('Request for "${request.url}"');
  }
}
