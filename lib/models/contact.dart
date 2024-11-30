import 'dart:convert';

import '../db/database_helper.dart';

class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final int groupId;
  final bool isFavorite;
  final String? picture;
  final String? note;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.groupId,
    this.isFavorite = false,
    this.picture,
    this.note,
  });

  @override
  String toString() {
    return '===Contact $id:\nName: $name\nPhone: $phone\nEmail: $email\nGroupID: $groupId\nIs favorite: $isFavorite\nPicture: $picture\nNote: $note';
  }

  Map<String, dynamic> toMap() {
    final map = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnPhone: phone,
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnGroupId: groupId,
      DatabaseHelper.columnIsFavorite: isFavorite ? 1 : 0,
      DatabaseHelper.columnPicture: picture,
      DatabaseHelper.columnNote: note,
    };
    
    if (id != null) {
      map[DatabaseHelper.columnId] = id;
    }
    
    return map;
  }

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map[DatabaseHelper.columnId],
      name: map[DatabaseHelper.columnName],
      phone: map[DatabaseHelper.columnPhone],
      email: map[DatabaseHelper.columnEmail],
      groupId: int.tryParse(map[DatabaseHelper.columnGroupId]) ?? -1,
      note: map[DatabaseHelper.columnNote],
      picture: map[DatabaseHelper.columnPicture],
      isFavorite: map[DatabaseHelper.columnIsFavorite] == 1,
    );
  }
}

class ContactGroup{
  final int? id;
  final String name;

  ContactGroup({this.id, required this.name});

  String toJson() {
    return json.encode({
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name
    });
  }

  static ContactGroup fromJson(String jsonString) {
    Map<String, dynamic> map = jsonDecode(jsonString);
    return ContactGroup(
      id: map[DatabaseHelper.columnId],
      name: map[DatabaseHelper.columnName],
    );
  }

  static ContactGroup fromMap(Map<String, dynamic> map) {
    return ContactGroup(
      id: map[DatabaseHelper.columnId],
      name: map[DatabaseHelper.columnName],
    );
  }

  @override
  String toString() {
    return '$id --- $name';
  }

  Map<String, dynamic> toMap() {
    final map = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name
    };

    if (id != null) {
      map[DatabaseHelper.columnId] = id;
    }

    return map;
  }
}
