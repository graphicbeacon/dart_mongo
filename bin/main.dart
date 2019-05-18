import 'package:dart_mongo/dart_mongo.dart';

main(List<String> arguments) async {
  int port = 8085;
  var server = await HttpServer.bind('localhost', port);
  Db db = Db('mongodb://localhost:27017/test');
  await db.open();

  print('Connected to database');

  server.transform(HttpBodyHandler()).listen((HttpRequestBody reqBody) async {
    var request = reqBody.request;
    var response = request.response;

    switch (request.uri.path) {
      case '/':
        response.write('Hello, World!');
        await response.close();
        break;
      case '/people':
        PeopleController(reqBody, db);
        break;
      default:
        response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found');
        await response.close();
    }
  });

  print('Server listening at http://localhost:$port');
}
