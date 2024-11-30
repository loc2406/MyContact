import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_contact/db/database_helper.dart';
import 'package:my_contact/screens/add_contact_screen.dart';
import 'package:my_contact/screens/contact_detail_screen.dart';

import '../models/contact.dart';
import '../utils/common.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {

  List<Contact> favoriteList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var favoriteContacts = await DatabaseHelper.allFavoriteContacts();

    setState(() {
      favoriteList = favoriteContacts.map((map) => Contact.fromMap(map)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Common.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(child: listContacts())
        ],
      ),
    );
  }

  ListView listContacts() {
    return ListView.builder(
        itemCount: favoriteList.length,
        itemBuilder: (BuildContext context, int index) {
          var contact = favoriteList[index];
          return itemContact(contact);
        });
  }

  ListTile itemContact(Contact contact) {
    return ListTile(
      title: Text(contact.name),
      subtitle: Text(contact.phone),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Common.primaryColor,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25), // radius = width/2 = 50/2
          child: contact.picture != null ? Image.file(File(contact.picture!), width: 50,height: 50, fit: BoxFit.cover) : const Icon(Icons.person, size: 25, color: Common.primaryColor),
        ),
      ),
      trailing: Icon(contact.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.red),
      onTap: () => navigateToDetail(contact),
    );
  }

  Widget handleLoadingImg(
      BuildContext context, Widget image, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return image;
    } else {
      return const CircularProgressIndicator(
        color: Common.primaryColor,
      );
    }
  }

  void navigateToDetail(Contact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ContactDetailScreen(),
          settings: RouteSettings(arguments: contact)
      ),
    );

    if (result == true) {
      await loadData();
    }
  }
}
