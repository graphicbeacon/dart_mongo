import 'dart:io';

import 'package:http_server/http_server.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PeopleController {
  PeopleController(this._reqBody, Db db)
      : _req = _reqBody.request,
        _store = db.collection('people') {
    handle();
  }

  HttpRequestBody _reqBody;
  final HttpRequest _req;
  final DbCollection _store;

  handle() async {
    switch (_req.method) {
      case 'GET':
        await handleGet();
        break;
      case 'POST':
        await handlePost();
        break;
      case 'PUT':
        await handlePut();
        break;
      case 'DELETE':
        await handleDelete();
        break;
      case 'PATCH':
        await handlePatch();
        break;
      default:
        _req.response.statusCode = 405;
    }

    await _req.response.close();
  }

  handleGet() async {
    _req.response.write(await _store.find().toList());
  }

  handlePost() async {
    _req.response.write(await _store.save(_reqBody.body));
  }

  handlePut() async {
    var id = int.parse(_req.uri.queryParameters['id']);
    var itemToPut = await _store.findOne(where.eq('id', id));

    if (itemToPut == null) {
      await _store.save(_reqBody.body);
    } else {
      await _store.update(itemToPut, _reqBody.body);
    }
  }

  handleDelete() async {
    var id = int.parse(_req.uri.queryParameters['id']);
    var itemToDelete = await _store.findOne(where.eq('id', id));
    if (itemToDelete != null) {
      _req.response.write(await _store.remove(itemToDelete));
    }
  }

  handlePatch() async {
    var id = int.parse(_req.uri.queryParameters['id']);
    var itemToPatch = await _store.findOne(where.eq('id', id));
    _req.response
        .write(await _store.update(itemToPatch, {r'$set': _reqBody.body}));
  }
}
