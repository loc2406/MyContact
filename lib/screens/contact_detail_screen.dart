import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_contact/db/database_helper.dart';
import 'package:my_contact/main.dart';
import 'package:my_contact/utils/my_dialog.dart';

import '../models/contact.dart';
import '../utils/common.dart';

class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({super.key});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreen();
}

class _ContactDetailScreen extends State<ContactDetailScreen> {
  GlobalKey formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late Contact originContact;
  bool isChanged = false;
  File? imageFile;
  int selectedGroupId = -1;
  List<Contact> allContacts= [];
  List<ContactGroup> allGroups = [];
  List<DropdownMenuItem<int>> groupItems = [];
  bool _isInitialized = false;

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

        if (originContact.groupId != -1) {
          try {
            selectedGroupId = allGroups
                .firstWhere((group) => group.id == originContact.groupId)
                .id ??
                -1;
          } catch (e) {
            selectedGroupId = -1;
          }
        } else {
          selectedGroupId = -1;
        }
      });
    } catch (e) {
      debugPrint('ERROR ===== loadGroups(): $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      initContact();
      _isInitialized = true;
    }
  }

  void initContact() {
    originContact = ModalRoute.of(context)?.settings.arguments as Contact;
    nameController.text = originContact.name;
    phoneController.text = originContact.phone;
    emailController.text = originContact.email ?? '';
    noteController.text = originContact.note ?? '';

    if (originContact.picture != null) {
      imageFile =
          originContact.picture != null ? File(originContact.picture!) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined),
              color: Colors.white,
              onPressed: () => Navigator.pop(context)),
          title: const Text('Detail Contact',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Common.primaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Common.buildImageWidget(
                  imageFile: imageFile,
                  onClick: () async {
                    await handleUpdateImage();
                  }),
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Common.buildInputWidget(
                          prefixIcon: Icons.person,
                          label: 'Name',
                          controller: nameController,
                          validateMethod: Common.validateName,
                          fieldChangeEvent: (data) => uploadDataChangedState()),
                      Common.buildInputWidget(
                          prefixIcon: Icons.phone,
                          label: 'Phone',
                          controller: phoneController,
                          validateMethod: (value) => Common.validatePhone(value, allContacts, originContact.id),
                          inputType: TextInputType.phone,
                          fieldChangeEvent: (data) => uploadDataChangedState()),
                      Common.buildInputWidget(
                          prefixIcon: Icons.email_outlined,
                          label: 'Email',
                          controller: emailController,
                          inputType: TextInputType.emailAddress,
                          fieldChangeEvent: (data) => uploadDataChangedState()),
                      buildGroupDropdownWidget(),
                      Common.buildInputWidget(
                          prefixIcon: Icons.note_outlined,
                          label: 'Note',
                          controller: noteController,
                          fieldChangeEvent: (data) => uploadDataChangedState())
                    ],
                  )),
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 50),
                child: isChanged // Chỉ hiển thị nút khi có thay đổi
                    ? ElevatedButton(
                        onPressed: showUpdateDialog,
                        style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Common.primaryColor)),
                        child: const Text('Update contact',
                            style: TextStyle(color: Colors.white)))
                    : null,
              )
            ],
          ),
        ));
  }

  Future<void> handleUpdateImage() async {
    File? newImage = await Common.getImageFromLibrary();
    if (newImage != null) {
      setState(() {
        imageFile = newImage;
      });
      uploadDataChangedState();
    }
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
          enabledBorder: Common.inputFieldBorderPrimary,
          focusedBorder: Common.inputFieldBorderPrimary,
        ),
        items: buildAllGroupItems(),
        onChanged: (int? value) {
          selectedGroupId = value!;
          uploadDataChangedState();
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

  void showUpdateDialog() {
    showDialog(
        context: context,
        builder: (context) => MyDialog.getAlertDialog(
            title: 'Update contact?',
            content: 'Are you sure to update this contact?',
            negative: 'No',
            positive: 'Yes',
            negativeAction: () => Navigator.pop(context),
            positiveAction: () {
              Navigator.pop(context);
              handleUpdateContact();
            }));
  }

  Future<void> handleUpdateContact() async {
    if ((formKey.currentState as FormState).validate()) {
      try {
        Map<String, dynamic> newInfo = {};

        if (isImageChanged()) {
          newInfo.addAll({DatabaseHelper.columnPicture: imageFile?.path});
        }
        if (isNameChanged()) {
          newInfo.addAll({DatabaseHelper.columnName: nameController.text});
        }
        if (isPhoneChanged()) {
          newInfo.addAll({DatabaseHelper.columnPhone: phoneController.text});
        }
        if (isEmailChanged()) {
          newInfo.addAll({
            DatabaseHelper.columnEmail: emailController.text.trim().isNotEmpty
                ? emailController.text.trim()
                : null
          });
        }
        if (isGroupChanged()) {
          newInfo.addAll({DatabaseHelper.columnGroupId: selectedGroupId});
        }

        if (isNoteChanged()) {
          newInfo.addAll({
            DatabaseHelper.columnNote: noteController.text.trim().isNotEmpty
                ? noteController.text.trim()
                : null
          });
        }

        int result =
            await DatabaseHelper.updateContact(originContact.id!, newInfo);

        if (!mounted) return;

        if (result > 0) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
              Common.getSnackBar(context, 'Update contact successful!'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Common.getSnackBar(context, 'Update contact failed!'));
        }
      } catch (e) {
        debugPrint('handleUpdateContact error: $e');
      }
    }
  }

  bool isImageChanged() => imageFile?.path != originContact.picture;

  bool isNameChanged() => nameController.text != originContact.name;

  bool isPhoneChanged() => phoneController.text != originContact.phone;

  bool isEmailChanged() => emailController.text != originContact.email;

  bool isGroupChanged() => selectedGroupId != originContact.groupId;

  bool isNoteChanged() => noteController.text != originContact.note;

  bool isDataChanged() {
    // debugPrint(' PRINT ===== ${isImageChanged()}');
    // debugPrint(' PRINT ===== ${isNameChanged()}');
    // debugPrint(' PRINT ===== ${isPhoneChanged()}');
    // debugPrint(' PRINT ===== ${isEmailChanged()}');
    // debugPrint(' PRINT ===== ${isGroupChanged()}');
    // debugPrint(' PRINT ===== ${isNoteChanged()}');
    return isImageChanged() ||
        isNameChanged() ||
        isPhoneChanged() ||
        isEmailChanged() ||
        isGroupChanged() ||
        isNoteChanged();
  }

  void uploadDataChangedState() {
    setState(() {
      isChanged = isDataChanged();
      debugPrint('IS CHANGED ===== $isChanged');
    });
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
