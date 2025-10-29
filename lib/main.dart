import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlite/product_admin_screen.dart';
import 'package:sqlite/product_list.dart';
import 'package:sqlite/my_cart.dart';
import 'package:sqlite/notifier.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo usar FFI si NO estamos en Android ni iOS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // En Android e iOS, sqflite usa la base nativa automáticamente
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Sqlite',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5EEDC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6B4F4F),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF6B4F4F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: ChangeNotifierProvider(
        create: (context) => CartNotifier(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ProductsList(),
    MyCart(),
    ProductAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shop Sqlite")),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shopping'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'My Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_business), label: 'Products'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
