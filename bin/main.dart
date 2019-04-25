import 'package:mongo_dart/mongo_dart.dart';

import 'package:dart_mongo/dart_mongo.dart' as dart_mongo;

main(List<String> arguments) async {
  Db db = Db('mongodb://localhost:27017/test');
  await db.open();

  print('Connected to database');

  DbCollection coll = db.collection('people');

  // Read people
  // var people = await coll.find().toList();
  var people = await coll.find(where.limit(5)).toList();
  print(people);

  var person = await coll
      // .findOne(where.match('first_name', 'B').and(where.gt('id', 40)));
      // .findOne(where.match('first_name', 'B').gt('id', 40));
      .findOne(where.jsQuery('''
      return this.first_name.startsWith('B') && this.id > 40;
      '''));
  print(person);

  // Create person
  await coll.save({
    'id': 101,
    'first_name': 'Jermaine',
    "last_name": "Gippes",
    "email": "cgippes2r@xinhuanet.com",
    "gender": "Female",
    "ip_address": "97.252.84.122"
  });
  print('Saved new person');

  // Update person
  await coll.update(await coll.findOne(where.eq('id', 101)), {
    r'$set': {'gender': 'Male'}
  });
  print('Updated person');
  print(await coll.findOne(where.eq('id', 101)));

  // Delete person
  await coll.remove(await coll.findOne(where.eq('id', 101)));
  print('Deleted person');
  print(await coll.findOne(where.eq('id', 101))); // null

  await db.close();
}
