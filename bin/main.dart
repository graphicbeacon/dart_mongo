import 'dart:io';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import 'package:dart_mongo/dart_mongo.dart' as dart_mongo;

main(List<String> arguments) async {
  int port = 8085;
  var server = await HttpServer.bind('localhost', port);
  Db db = Db('mongodb://localhost:27017/test');
  await db.open();

  print('Connected to database');

  DbCollection coll = db.collection('people');

  server.listen((HttpRequest request) async {
    switch (request.uri.path) {
      case '/':
        request.response
          ..write('Hello, World!')
          ..close();
        break;
      case '/people':

        // Handle GET request
        if (request.method == 'GET') {
          request.response.write(await coll.find().toList());
        }
        // Handle POST request
        else if (request.method == 'POST') {
          var content = await request.transform(Utf8Decoder()).join();
          var document = json.decode(content);
          await coll.save(document);
        }
        // Handle PUT request
        else if (request.method == 'PUT') {
          var id = int.parse(request.uri.queryParameters['id']);
          var content = await request.transform(Utf8Decoder()).join();
          var document = json.decode(content);
          var itemToReplace = await coll.findOne(where.eq('id', id));

          if (itemToReplace == null) {
            await coll.save(document);
          } else {
            await coll.update(itemToReplace, document);
          }
        }
        // Handle DELETE request
        else if (request.method == 'DELETE') {
          var id = int.parse(request.uri.queryParameters['id']);
          var itemToDelete = await coll.findOne(where.eq('id', id));
          await coll.remove(itemToDelete);
        }
        // Handle PATCH request
        else if (request.method == 'PATCH') {
          var id = int.parse(request.uri.queryParameters['id']);
          var content = await request.transform(Utf8Decoder()).join();
          var document = json.decode(content);
          var itemToPatch = await coll.findOne(where.eq('id', id));
          await coll.update(itemToPatch, {
            r'$set': document,
          });
        }
        await request.response.close();
        break;
      default:
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found');
        await request.response.close();
    }
  });

  print('Server listening at http://localhost:$port');
}
