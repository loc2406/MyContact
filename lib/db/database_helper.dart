import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/contact.dart';

class DatabaseHelper {
  static const String dbFileName = 'myDb.db';
  static const String tableContacts = 'contacts';
  static const String tableContactGroups = 'contact_groups';
  static const int dbVersion = 1;
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnPhone = 'phone';
  static const String columnEmail = 'email';
  static const String columnGroupId = 'groupId';
  static const String columnIsFavorite = 'isFavorite';
  static const String columnPicture = 'picture';
  static const String columnNote = 'note';
  static Database? db;

  static Future<void> createTableContact(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableContacts(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            $columnName TEXT NOT NULL, 
            $columnPhone TEXT NOT NULL,
            $columnEmail TEXT,
            $columnGroupId TEXT, 
            $columnIsFavorite INTEGER DEFAULT 0,
            $columnPicture TEXT,
            $columnNote TEXT
            );
        ''');
    } catch (e) {
      debugPrint('ERROR ===== createTableContact(): $e');
    }
  }

  static Future<void> createTableContactGroups(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE $tableContactGroups(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            $columnName TEXT NOT NULL
            );
        ''');
    } catch (e) {
      debugPrint('ERROR --- createTableContactGroups(): $e');
    }
  }

  static Future<Database> getDatabase() async {
    return openDatabase(
      dbFileName,
      onCreate: (db, version) async {
        await createTableContact(db);
        await createTableContactGroups(db);
      },
      version: dbVersion,
    );
  }

  static Future<int> insertContact(Contact contact) async {
    db ??= await getDatabase();
    return await db!.insert(tableContacts, contact.toMap());
  }

  static Future<List<Map<String, Object?>>> allContacts() async {
    db ??= await getDatabase();
    return await db!.query(tableContacts);
  }

  static Future<List<Map<String, Object?>>> allFavoriteContacts() async {
    db ??= await getDatabase();
    return await db!
        .query(tableContacts, where: 'isFavorite = ?', whereArgs: [1]);
  }

  static Future<int> updateContact(int id, Map<String, dynamic> newInfo) async {
    db ??= await getDatabase();
    return await db!.update(tableContacts, newInfo,
        where: 'id = ?',
        whereArgs: [id]);
  }

  static Future<int> deleteContact(int id) async {
    db ??= await getDatabase();
    return await db!.delete(
      tableContacts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateFavoriteContact(int id, bool isFavorite) async {
    db ??= await getDatabase();
    return await db!.update(
      tableContacts,
      {columnIsFavorite: isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, Object?>>> allGroups() async {
    db ??= await getDatabase();
    var list = await db!.query(tableContactGroups);
    return list;
  }

  static Future<int> insertGroup(ContactGroup group) async {
    db ??= await getDatabase();
    return await db!.insert(tableContactGroups, group.toMap());
  }

  static Future<int> updateGroup(ContactGroup group) async {
    db ??= await getDatabase();
    return await db!.update(
      tableContactGroups,
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  static Future<int> deleteGroup(int id) async {
    db ??= await getDatabase();
    return await db!.delete(
      tableContactGroups,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
