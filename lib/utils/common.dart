import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_contact/db/database_helper.dart';
import 'package:my_contact/models/contact.dart';

class Common {
  static const Color primaryColor = Colors.lightBlueAccent;
  static const Color errColor = Colors.red;

  static const OutlineInputBorder inputFieldBorderPrimary = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: primaryColor));

  static const OutlineInputBorder inputFieldBorderError = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: errColor));

  static OutlineInputBorder inputFieldBorderCustom(Color customColor){
    return OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: customColor));
  }

  static SnackBar getSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
  }

  static Future<File?> getImageFromLibrary() async {
    ImagePicker imagePicker = ImagePicker();
    try {
      XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Nén ảnh để giảm dung lượng
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('ERROR ===== getImage(): $e');
    }
    return null;
  }

  static Widget buildImageWidget(
      {required File? imageFile, required void Function()? onClick}) {
    return Container(
      margin: const EdgeInsets.only(top: 50, bottom: 30),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Common.primaryColor,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: imageFile != null
                ? Image.file(
                    imageFile,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: Icon(Icons.person, size: 50, color: Colors.black)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Common.primaryColor,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: onClick,
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Container buildInputWidget(
      {required IconData prefixIcon,
      required String label,
      required TextEditingController controller,
      TextInputType? inputType,
      String? Function(String?)?
          validateMethod, // truyền vào 1 hàm nhận 1 tham số kiểu String? và trả về giá trị kiểu String?
      void Function(String)? fieldChangeEvent}) {
    return Container(
        margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
              // call() là phương thức đặc biệt cho phép gọi 1 function object như 1 hàm thông thường khi có tham chiếu
              prefixIcon: Icon(prefixIcon, color: Colors.black),
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: Common.inputFieldBorderPrimary,
              errorBorder: Common.inputFieldBorderError,
              focusedBorder: Common.inputFieldBorderPrimary,
              focusedErrorBorder: Common.inputFieldBorderError),
          validator: validateMethod,
          // Validate khi người dùng nhập liệu
          keyboardType: inputType,
          onChanged: fieldChangeEvent,
        ));
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name can not be empty!';
    }

    RegExp namePattern = RegExp(r'^[a-zA-ZÀ-ỹ\s0-9]+$', unicode: true);
    if (!namePattern.hasMatch(name)) {
      return 'Name must not contains special character!';
    }

    return null;
  }

  static String? validatePhone(String? phone, List<Contact> allContacts, int? currentContactId) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone can not be empty!';
    }

    RegExp phonePattern = RegExp(r'^(0?)([35789])[0-9]{8}$');
    if (!phonePattern.hasMatch(phone)) {
      return 'Invalid phone!';
    }

    bool isExisted = allContacts.any((contact) => contact.phone == phone && contact.id != currentContactId);
    if (isExisted){
      return 'This phone is existed!';
    }

    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email can not be empty!';
    }

    RegExp emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailPattern.hasMatch(email)) {
      return 'Invalid email!';
    }

    return null;
  }

  static Future<String?> validateGroup(String? groupName) async {
    if (groupName == null || groupName.trim().isEmpty) {
      return 'Group can not be empty!';
    }

    RegExp groupPattern = RegExp(r'^[a-zA-ZÀ-ỹ\s0-9]+$', unicode: true);
    if (!groupPattern.hasMatch(groupName)) {
      return 'Group must not contains special character!';
    }

    var allGroups = (await DatabaseHelper.allGroups())
        .map((groupMap) => ContactGroup.fromMap(groupMap))
        .toList();
    if (allGroups.any((group) => group.name == groupName)) {
      return 'Group is existed!';
    }

    return null;
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
}
