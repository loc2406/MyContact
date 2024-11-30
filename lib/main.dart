import 'package:flutter/material.dart';
import 'package:my_contact/screens/favorite_screen.dart';
import 'package:my_contact/screens/group_screen.dart';
import 'package:my_contact/screens/home_screen.dart';
import 'package:my_contact/utils/common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // searchBarTheme: const SearchBarThemeData(
        //   elevation: WidgetStatePropertyAll(0),
        //   backgroundColor: WidgetStatePropertyAll(Colors.white)
        // ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  // Key để refresh FavoriteScreen
  final GlobalKey favoriteKey = GlobalKey();

  // Danh sách các màn hình tương ứng với mỗi tab
  final List<Widget> screens = [
    const HomeScreen(),
    FavoriteScreen(key: GlobalKey()),
    const GroupScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 1) {
        final favoriteScreen = screens[1].key as GlobalKey;
        (favoriteScreen.currentState as FavoriteScreenState).loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Common.primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
        ],
      ),
    );
  }
}
