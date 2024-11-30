import 'package:flutter/material.dart';

import 'common.dart';

class MyDialog {
  static AlertDialog getGroupDialog({
    required String title,
    String? content,
    TextEditingController? controller,
    String? fieldLabel, String? fieldHint,
    required String negative, required void Function() negativeAction,
    required String positive, required void Function() positiveAction, required Color color}) {
    return AlertDialog(
        title: Text(title, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: controller != null ? TextFormField(
          controller: controller,
          decoration: InputDecoration(
              labelText: fieldLabel,
              labelStyle: TextStyle(color: color),
              hintText: fieldHint,
            enabledBorder: Common.inputFieldBorderCustom(color),
            focusedBorder: Common.inputFieldBorderCustom(color)
          ),
          autofocus: true,
        ) : Text(content!),
        actions: [
          TextButton(
              onPressed: negativeAction,
              child: Text(negative, style: const TextStyle(color: Colors.grey))
          ),
          TextButton(
              onPressed: positiveAction,
              child: Text(positive, style: TextStyle(color: color)))
        ],
    );
  }

  static AlertDialog getAlertDialog({
    required String title,
    required String content,
    required String negative, required void Function() negativeAction,
    required String positive, required void Function() positiveAction}) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(color: Common.primaryColor, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: negativeAction,
            child: Text(negative, style: const TextStyle(color: Colors.grey))
        ),
        TextButton(
            onPressed: positiveAction,
            child: Text(positive, style: const TextStyle(color: Common.primaryColor)))
      ],
    );
  }
}