import 'dart:io';

/// Serves a built site so it can be looked at before it is deployed.
///
/// ```
/// dart run bin/build.dart && dart run bin/serve.dart
/// ```
///
/// It is deliberately dumb: static files, directory indexes, and the site's own
/// `404.html` for anything missing — the same three behaviours GitHub Pages
/// has, so what you see locally is what gets published.
Future<void> main(List<String> arguments) async {
  final root = Directory(arguments.isEmpty ? 'build/site' : arguments.first);
  if (!root.existsSync()) {
    stderr.writeln('jasper: ${root.path} does not exist — run bin/build.dart first');
    exitCode = 66; // EX_NOINPUT
    return;
  }

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Serving ${root.path} on http://localhost:$port/ — Ctrl-C to stop');

  await for (final request in server) {
    await _respond(request, root);
  }
}

Future<void> _respond(HttpRequest request, Directory root) async {
  final path = Uri.decodeComponent(request.uri.path);
  final candidates = <String>[
    '${root.path}$path',
    '${root.path}$path${path.endsWith('/') ? '' : '/'}index.html',
  ];

  for (final candidate in candidates) {
    final file = File(candidate);
    if (file.existsSync() && FileSystemEntity.isFileSync(candidate)) {
      request.response.headers.contentType = _contentType(candidate);
      await request.response.addStream(file.openRead());
      await request.response.close();
      return;
    }
  }

  final notFound = File('${root.path}/404.html');
  request.response.statusCode = HttpStatus.notFound;
  if (notFound.existsSync()) {
    request.response.headers.contentType = ContentType.html;
    await request.response.addStream(notFound.openRead());
  } else {
    request.response.write('Not found');
  }
  await request.response.close();
}

ContentType _contentType(String path) {
  if (path.endsWith('.html')) return ContentType.html;
  if (path.endsWith('.css')) return ContentType('text', 'css', charset: 'utf-8');
  if (path.endsWith('.js')) return ContentType('text', 'javascript', charset: 'utf-8');
  if (path.endsWith('.svg')) return ContentType('image', 'svg+xml', charset: 'utf-8');
  if (path.endsWith('.xml')) return ContentType('application', 'xml', charset: 'utf-8');
  if (path.endsWith('.txt')) return ContentType.text;
  return ContentType.binary;
}
