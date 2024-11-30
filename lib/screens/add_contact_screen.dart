import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_contact/db/database_helper.dart';
import 'package:my_contact/main.dart';

import '../models/contact.dart';
import '../utils/common.dart';

/* Thêm quyền cho phép truy cập ảnh từ thư viện thiết bị để có thể truy cập ảnh:
* -IOS (ios/Runner/Info.plist):
*         <dict>
                      <key>NSPhotoLibraryUsageDescription</key>
                      <string>Need to access photo library to pick contact image</string>
                       <!-- ... -->
            </dict>

* - Android (android/app/src/main/AndroidManifest.xml):
*        <manifest ...>
              <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
              <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
              <!-- ... -->
          </manifest>
* */

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  GlobalKey formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  File? imageFile;
  List<Contact> allContacts = [];
  List<ContactGroup> allGroups = [];
  List<DropdownMenuItem<int>> groupItems = [];
  int selectedGroupId = -1;

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      var currentContacts = await DatabaseHelper.allContacts();
      var currentGroups = await DatabaseHelper.allGroups();
      setState(() {
        allContacts = currentContacts.map((map) => Contact.fromMap(map)).toList();
        allGroups = currentGroups.map((map) => ContactGroup.fromMap(map)).toList();
      });
    } catch (e) {
      debugPrint('ERROR ===== loadGroups(): $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined),
              color: Colors.white,
              onPressed: () => Navigator.pop(context)),
          title:
              const Text('Add Contact', style: TextStyle(color: Colors.white)),
          backgroundColor: Common.primaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Common.buildImageWidget(
                  imageFile: imageFile,
                  onClick: () async =>
                      {imageFile = await Common.getImageFromLibrary(), setState(() {})}),
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Common.buildInputWidget(
                          prefixIcon: Icons.person,
                          label: 'Name',
                          controller: nameController,
                          validateMethod: Common.validateName),
                      Common.buildInputWidget(
                          prefixIcon: Icons.phone,
                          label: 'Phone',
                          controller: phoneController,
                          validateMethod: (value) => Common.validatePhone(value, allContacts, null),
                          inputType: TextInputType.phone),
                      Common.buildInputWidget(
                          prefixIcon: Icons.email_outlined,
                          label: 'Email',
                          controller: emailController,
                          inputType: TextInputType.emailAddress),
                      buildGroupDropdownWidget(),
                      Common.buildInputWidget(
                          prefixIcon: Icons.note_outlined,
                          label: 'Note',
                          controller: noteController)
                    ],
                  )),
              Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 50),
                  child: ElevatedButton(
                      onPressed: handleAddContact,
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Common.primaryColor)),
                      child: const Text('Add contact',
                          style: TextStyle(color: Colors.white))))
            ],
          ),
        ));
  }

  Container buildGroupDropdownWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: DropdownButtonFormField<int>(
        value: selectedGroupId,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.group,
            color: Colors.black,
          ),
          labelText: 'Select group',
          labelStyle: TextStyle(color: Common.primaryColor),
          enabledBorder:Common.inputFieldBorderPrimary,
          focusedBorder: Common.inputFieldBorderPrimary,
        ),
        items: buildAllGroupItems(),
        onChanged: (int? value) {
          setState(() {
            selectedGroupId = value!;
          });
        },
      ),
    );
  }

  List<DropdownMenuItem<int>> buildAllGroupItems() {
    groupItems = [
      const DropdownMenuItem<int>(
        value: -1,
        child: Text(
          'No select',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      )
    ];

    groupItems.addAll(allGroups
        .map((group) => DropdownMenuItem<int>(
              value: group.id,
              child: Text(
                group.name,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ))
        .toList());
    return groupItems;
  }

  Future<void> handleAddContact() async {
    if ((formKey.currentState as FormState).validate()) {
      try {
        Contact newContact = Contact(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
          groupId: selectedGroupId,
          note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
          picture: imageFile?.path,
        );

        debugPrint('HANDLE ADD CONTACT --- ${newContact.toString()}');

        int result = await DatabaseHelper.insertContact(newContact);

        if (mounted) {
          if (result > 0) {
            Navigator.pop(context,
                true);
            ScaffoldMessenger.of(context).showSnackBar(
                Common.getSnackBar(context, 'Add contact successfully!'));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                Common.getSnackBar(context, 'Add contact failed!'));
          }
        }
      } catch (e) {
        debugPrint('ERROR ===== handleAddContact(): $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    noteController.dispose();
  }
}
