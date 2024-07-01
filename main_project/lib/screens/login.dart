import 'package:flutter/material.dart';
import 'package:main_project/screens/registerPage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:crypto/crypto.dart';
import 'package:main_project/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // for utf8.encode
import 'package:main_project/screens/fooddonation.dart';
import 'package:main_project/main.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  static const route = '/login/';
  static const String routename = 'LoginPage';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loginUser(BuildContext context) async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection('users');
    var hashedPassword = hashPassword(_passwordController.text);

    var user = await collection.findOne({
      'email': _emailController.text,
      'password': hashedPassword
    });
    await db.close();

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', user['_id'].toString());
      prefs.setString('name', user['name']);
      prefs.setString('surname', user['surname']);
      prefs.setString('email', user['email']);

      prefs.setString('username', user['name']); 
      prefs.setString('uniqueCode', user['uniqueCode']); 
      prefs.setStringList('groups', List<String>.from(user['groups']));

      print('Stored groups: ${user['groups']}'); 

      Navigator.pushReplacementNamed(context, FoodDonation.route);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login Failed"),
            content: Text("Incorrect email or password."),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LoginPage.routename),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => loginUser(context),
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                  print('Sign up clicked');
                },
                child: Text(
                  "Don't have an account? Sign up here",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
