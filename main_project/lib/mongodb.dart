import 'dart:developer';
import 'package:main_project/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? _db; 
  static MongoDatabase? _instance;  // Singleton instance

  MongoDatabase._createInstance();  // Private constructor

  static Future<MongoDatabase> getInstance() async {
    if (_instance == null) {
      _instance = MongoDatabase._createInstance();
      await _instance!._connect();
    }
    return _instance!;
  }

  Future<void> _connect() async {
    if (_db == null || _db!.state == State.CLOSED) {
      try {
        _db = await Db.create(MONGO_URL);  // Initialize db
        await _db!.open();  // Use the ! operator to assert that db is not null
        inspect(_db);
      } catch (e) {
        log('Error connecting to MongoDB: $e');
        rethrow;
      }
    }
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    if (_db == null || _db!.state == State.CLOSED) {
      throw Exception('Database is not connected');
    }
    try {
      var collection = _db!.collection('Users'); 
      await collection.insertOne(userData);
    } catch (e) {
      log('Error inserting user data: $e');
      rethrow;
    }
  }

  Future<DbCollection> getCollection(String collectionName) async {
    if (_db == null || _db!.state == State.CLOSED) {
      throw Exception('Database is not connected');
    }
    return _db!.collection(collectionName);
  }

  Future<void> close() async {
    if (_db != null && _db!.state == State.OPEN) {
      await _db!.close();  // Ensure db is not null before calling close
    }
  }
}
