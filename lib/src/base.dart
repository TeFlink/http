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

  entryPoint() {
    server.serve();
  }
}

class TeFlinkHttp {
  TeFlinkHttp({this.port}) {
    handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler((request) => _echoRequest(request));
  }

  int port;
  dynamic handler;

  void serve() async {
    var server = await io.serve(handler, _hostname, port);
    print('Serving at http://${server.address.host}:${server.port}');
  }

  shelf.Response _echoRequest(shelf.Request request) {
    return shelf.Response.ok('Request for "${request.url}"');
  }
}

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler((request) => _echoRequest(request));

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

shelf.Response _echoRequest(shelf.Request request) {
  return shelf.Response.ok('Request for "${request.url}"');
}
