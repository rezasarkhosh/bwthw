import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:main_project/constant.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import 'dart:math';
import 'package:main_project/screens/login.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  static const route = '/register/';
  static const String routename = 'RegisterPage';

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  List<String> _groups = [
    'Lactating Woman',
    'Older than 65',
    'Pregnant Woman',
    'Adolescent Girl',
    'Parent of Children Under 5'
  ];
  Map<String, bool> _selectedGroups = {};

  @override
  void initState() {
    super.initState();
    _groups.forEach((group) {
      _selectedGroups[group] = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void registerUser() async {
    var db = await mongo.Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection('users');
    var hashedPassword = hashPassword(_passwordController.text);
    var uniqueCode = generateUniqueCode(12);
    await collection.insertOne({
      'name': _nameController.text,
      'surname': _surnameController.text,
      'email': _emailController.text,
      'password': hashedPassword,  
      'uniqueCode': uniqueCode,  
      'groups': _selectedGroups.entries.where((entry) => entry.value).map((entry) => entry.key).toList(), 
    });
    await db.close();

    Navigator.pushReplacementNamed(context, '/');  
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);  
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateUniqueCode(int length) {
    const String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(RegisterPage.routename),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(
                  labelText: 'Surname',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
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
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ..._groups.map((group) {
                return CheckboxListTile(
                  title: Text(group),
                  value: _selectedGroups[group],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedGroups[group] = value!;
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerUser,
                child: Text('Register'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
