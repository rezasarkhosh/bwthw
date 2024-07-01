import 'package:flutter/material.dart';
import 'package:main_project/mongodb.dart';
import 'package:main_project/screens/foodDonation.dart';
import 'package:main_project/screens/login.dart';
import 'package:main_project/screens/profilePage.dart';
import 'package:main_project/screens/registerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.getInstance();  // Ensure the database is connected
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        FoodDonation.route: (context) => FoodDonation(),
        LoginPage.route: (context) => LoginPage(),
        RegisterPage.route: (context) => const RegisterPage(),
        ProfilePage.route: (context) => ProfilePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (_selectedIndex == index) {
      return; // Do nothing if the current index is the same as the tapped index
    }
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getString('userId') != null;
      if (isLoggedIn) {
        Navigator.pushNamed(context, ProfilePage.route);
      } else {
        Navigator.pushNamed(context, LoginPage.route);
      }
    } else if (index == 0) {
      // Handle home navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harvest Hero', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.pushNamed(context, LoginPage.route);
              print('Login button pressed');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.cyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Icon(Icons.food_bank, color: Colors.teal),
                  title: Text('Food Donation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: Icon(Icons.arrow_forward, color: Colors.teal),
                  onTap: () {
                    Navigator.pushNamed(context, FoodDonation.route);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
