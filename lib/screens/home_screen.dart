import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_contact/db/database_helper.dart';
import 'package:my_contact/screens/add_contact_screen.dart';
import 'package:my_contact/screens/contact_detail_screen.dart';

import '../models/contact.dart';
import '../utils/common.dart';
import '../utils/my_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> currentContacts = [];
  List<ContactGroup> currentGroups = [];
  List<Contact> orginalContacts = [];
  bool isSearching = false;
  String searchKeyword = '';
  ContactGroup? selectedGroup;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      var allContacts = await DatabaseHelper.allContacts();
      var allGroups = await DatabaseHelper.allGroups();

      setState(() {
        currentContacts =
            allContacts.map((map) => Contact.fromMap(map)).toList();
        currentGroups =
            allGroups.map((map) => ContactGroup.fromMap(map)).toList();
        orginalContacts = currentContacts;
      });
    } catch (e) {
      debugPrint('ERROR ===== loadData(): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchController.clear();
                    handleSearchContact('');
                  });
                },
              )
            : null,
        title: isSearching
            ? TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                onChanged: handleSearchContact,
                autofocus: true, // Tự động focus khi hiện search bar
              )
            : const Text('Homepage', style: TextStyle(color: Colors.white)),
        backgroundColor: Common.primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  handleSearchContact('');
                }
              });
            },
            icon: Icon(isSearching ? Icons.close : Icons.search,
                color: Colors.white),
          ),
          if (!isSearching) // Chỉ hiện nút add khi không trong chế độ tìm kiếm
            IconButton(
                onPressed: navigateAddContactScreen,
                icon: const Icon(Icons.add, color: Colors.white))
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: orginalContacts.isNotEmpty
                  ? Column(
                      children: [
                        buildFilterWidget(),
                        Expanded(child: buildListContactsWidget()),
                      ],
                    )
                  : Center(
                      child: isSearching
                          ? const Text('Contact not found!')
                          : Center(
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: const Text(
                                      'You don\'t have any contact!\nPress \"+\" to add new contact!',
                                      textAlign: TextAlign.center)))))
        ],
      ),
    );
  }

  void handleSearchContact(String keyword) {
    setState(() {
      searchKeyword = keyword;
      updateCurrentContacts();
    });
  }

  void handleFilterSelected(ContactGroup? filterGroup) {
    setState(() {
      selectedGroup = filterGroup;
      updateCurrentContacts();
    });
  }

  void updateCurrentContacts() {
    var filteredContacts = orginalContacts;

    if (selectedGroup != null) {
      filteredContacts = filteredContacts
          .where((contact) => contact.groupId == selectedGroup!.id)
          .toList();
    }

    if (searchKeyword.isNotEmpty) {
      filteredContacts = filteredContacts
          .where((contact) =>
              contact.name
                  .toLowerCase()
                  .contains(searchKeyword.toLowerCase()) ||
              contact.email
                      ?.toLowerCase()
                      .contains(searchKeyword.toLowerCase()) ==
                  true ||
              contact.phone.toLowerCase().contains(searchKeyword.toLowerCase()))
          .toList();
    }

    isSearching = searchKeyword.isNotEmpty;
    currentContacts = filteredContacts;
  }

  Widget buildFilterWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text('Filter by: ',
              style: TextStyle(
                  color: Common.primaryColor, fontWeight: FontWeight.bold)),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Cuộn theo chiều ngang
            child: Row(
              children: buildFilterButton(),
            ),
          )),
        ],
      ),
    );
  }

  List<Container> buildFilterButton() {
    var filterButtons = [
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: OutlinedButton(
              onPressed: () => handleFilterSelected(null),
              child: const Text(
                'All',
                style: TextStyle(color: Colors.black),
              )))
    ];
    filterButtons.addAll(currentGroups
        .map((group) => Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: OutlinedButton(
                onPressed: () => handleFilterSelected(group),
                child: Text(
                  group.name,
                  style: const TextStyle(color: Colors.black),
                ))))
        .toList());
    return filterButtons;
  }

  ListView buildListContactsWidget() {
    return ListView.builder(
        itemCount: currentContacts.length,
        itemBuilder: (BuildContext context, int index) {
          var contact = currentContacts[index];
          return buildItemContact(contact);
        });
  }

  ListTile buildItemContact(Contact contact) {
    return ListTile(
      title: Text(contact.name),
      subtitle: Text(
          '${contact.phone} --- Group: ${getGroupNameById(contact.groupId) ?? 'None'}'),
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
          child: contact.picture != null
              ? Image.file(File(contact.picture!),
                  width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.person, size: 25, color: Common.primaryColor),
        ),
      ),
      trailing: IconButton(
          icon: contact.isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border),
          color: Colors.red,
          onPressed: () {
            contact.isFavorite
                ? showDeleteFavoriteContactDialog(contact)
                : showAddFavoriteContactDialog(contact);
          }),
      onTap: () => navigateToDetail(contact),
      onLongPress: () => showDeleteContactDialog(contact),
    );
  }

  String? getGroupNameById(int id) {
    try {
      var result = currentGroups.firstWhere((contact) => contact.id == id).name;
      return result;
    } catch (e) {
      return null;
    }
  }

  void showAddFavoriteContactDialog(Contact contact) {
    showDialog(
        context: context,
        builder: (context) {
          return MyDialog.getAlertDialog(
              title: 'Add favorite contact?',
              content:
                  'Do you want to add \"${contact.name}\" to favorite contacts?',
              negative: 'No',
              negativeAction: () {
                Navigator.pop(context);
              },
              positive: 'Yes',
              positiveAction: () {
                handleAddFavoriteContact(contact);
              });
        });
  }

  Future<void> handleAddFavoriteContact(Contact contact) async {
    try {
      int result =
          await DatabaseHelper.updateFavoriteContact(contact.id!, true);

      if (mounted) {
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(Common.getSnackBar(
              context, 'Add favorite contact successfully!'));
          loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Common.getSnackBar(context, 'Add favorite contact failed!'));
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('ERROR ===== handleAddFavoriteContact(): $e');
        Navigator.pop(context);
      }
    }
  }

  void showDeleteFavoriteContactDialog(Contact contact) {
    showDialog(
        context: context,
        builder: (context) {
          return MyDialog.getAlertDialog(
              title: 'Delete favorite contact?',
              content:
                  'Do you want to delete \"${contact.name}\" from favorite contacts?',
              negative: 'No',
              negativeAction: () {
                Navigator.pop(context);
              },
              positive: 'Yes',
              positiveAction: () {
                handleDeleteFavoriteContact(contact);
              });
        });
  }

  Future<void> handleDeleteFavoriteContact(Contact contact) async {
    try {
      int result =
          await DatabaseHelper.updateFavoriteContact(contact.id!, false);

      if (mounted) {
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(Common.getSnackBar(
              context, 'Delete favorite contact successfully!'));
          loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Common.getSnackBar(context, 'Delete favorite contact failed!'));
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('ERROR ===== handleDeleteFavoriteContact(): $e');
        Navigator.pop(context);
      }
    }
  }

  void navigateAddContactScreen() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddContactScreen()));

    if (result == true) {
      await loadData();
    }
  }

  Future<void> navigateToDetail(Contact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ContactDetailScreen(),
          settings: RouteSettings(arguments: contact)),
    );

    if (result == true) {
      await loadData();
    }
  }

  void showDeleteContactDialog(Contact contact) {
    showDialog(
        context: context,
        builder: (context) {
          return MyDialog.getAlertDialog(
              title: 'Delete contact?',
              content: 'Do you want to delete \"${contact.name}\"?',
              negative: 'No',
              negativeAction: () {
                Navigator.pop(context);
              },
              positive: 'Yes',
              positiveAction: () {
                handleDeleteContact(contact);
              });
        });
  }

  Future<void> handleDeleteContact(Contact contact) async {
    try {
      int result = await DatabaseHelper.deleteContact(contact.id!);

      if (mounted) {
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              Common.getSnackBar(context, 'Delete contact successfully!'));
          loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Common.getSnackBar(context, 'Delete contact failed!'));
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('ERROR ===== handleDeleteContact(): $e');
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
