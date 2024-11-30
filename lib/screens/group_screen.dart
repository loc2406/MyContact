import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_contact/db/database_helper.dart';

import '../models/contact.dart';
import '../utils/common.dart';
import '../utils/my_dialog.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<ContactGroup> groups = [];
  final TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      var allGroups = await DatabaseHelper.allGroups();
      setState(() {
        groups = allGroups.map((map) => ContactGroup.fromMap(map)).toList();
      });
    } catch (e) {
      debugPrint('ERROR ===== loadGroups error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups', style: TextStyle(color: Colors.white)),
        backgroundColor: Common.primaryColor,
        actions: [
          IconButton(onPressed: showAddGroupDialog, icon: const Icon(Icons.add, color: Colors.white))
        ],
      ),
      body: groups.isEmpty
          ? Center(
              child: Text(
                'No groups available.\nPress + to add new group.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) => itemGroup(groups[index]),
            ),
      );
  }

  ListTile itemGroup(ContactGroup group) {
    return ListTile(
        title: Text(group.name),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => showUpdateGroupDialog(group),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () => showDeleteGroupDialog(group),
              ),
            ],
          ),
        ));
  }

  Future<void> showAddGroupDialog() async {
    groupNameController.clear(); // Clear previous input

    return showDialog(
        context: context,
        builder: (context) => MyDialog.getGroupDialog(
            title: 'Insert',
            controller: groupNameController,
            fieldLabel: 'Group name:',
            fieldHint: 'Enter new group name:',
            negative: 'Cancel',
            negativeAction: () {
              Navigator.pop(context);
            },
            positive: 'Insert',
            positiveAction: () async {
              await handleInsertNewGroup();
            },
            color: Colors.lightGreen));
  }

  Future<void> showUpdateGroupDialog(ContactGroup group) async {
    groupNameController.text = group.name;

    return showDialog(
        context: context,
        builder: (context) => MyDialog.getGroupDialog(
            title: 'Update',
            controller: groupNameController,
            fieldLabel: 'Group name:',
            fieldHint: 'Edit group name:',
            negative: 'Cancel',
            negativeAction: () {
              Navigator.pop(context);
            },
            positive: 'Update',
            positiveAction: () async {
              await handleUpdateGroup(group.id);
            },
            color: Colors.orange));
  }

  Future<void> showDeleteGroupDialog(ContactGroup group) async {
    return showDialog(
        context: context,
        builder: (context) =>
            MyDialog.getGroupDialog(
                title: 'Delete',
                content: 'Are you sure you want to delete "${group.name}"?',
                negative: 'Cancel',
                negativeAction: () {
                  Navigator.pop(context);
                },
                positive: 'Delete',
                positiveAction: () async {
                  await handleDeleteGroup(group.id!);
                },
                color: Colors.red));
  }

  Future<void> handleInsertNewGroup() async {
    String? invalidMessage = await Common.validateGroup(groupNameController.text);
    if (invalidMessage == null) {
      ContactGroup newGroup = ContactGroup(
        name: groupNameController.text.trim(),
      );

      int result = await DatabaseHelper.insertGroup(newGroup);

      if (!mounted) return;
      Navigator.pop(context);

      if (result > 0) {
        loadGroups();
        ScaffoldMessenger.of(context).showSnackBar(
          Common.getSnackBar(context, 'Group inserted successfully!'),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Common.getSnackBar(context, 'Group inserted failed!'),
        );
      }
    }
    else{
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        Common.getSnackBar(context, invalidMessage),
      );
    }
  }

  Future<void> handleUpdateGroup(int? id) async {
    String? invalidMessage = await Common.validateGroup(groupNameController.text);
    if (invalidMessage == null) {
      ContactGroup updatedGroup = ContactGroup(
        id: id,
        name: groupNameController.text.trim(),
      );

      int result = await DatabaseHelper.updateGroup(updatedGroup);

      if (!mounted) return;
      Navigator.pop(context);

      if (result > 0) {
        loadGroups();
        ScaffoldMessenger.of(context).showSnackBar(
          Common.getSnackBar(context, 'Group updated successfully!'),
        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          Common.getSnackBar(context, 'Group updated failed!'),
        );
      }
    }else{
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        Common.getSnackBar(context, invalidMessage),
      );
    }
  }

  Future<void> handleDeleteGroup(int id) async {
    int result = await DatabaseHelper.deleteGroup(id);

    if (!mounted) return;
    Navigator.pop(context);

    if (result > 0) {
      loadGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        Common.getSnackBar(context, 'Group deleted successfully!'),
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        Common.getSnackBar(context, 'Group deleted failed!'),
      );
    }
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }
}
