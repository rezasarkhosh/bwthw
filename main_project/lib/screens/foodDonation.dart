import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:main_project/constant.dart'; 
import 'dart:math';  
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:main_project/screens/login.dart';

class FoodDonation extends StatefulWidget {
  FoodDonation({Key? key}) : super(key: key);
  static const route = '/food-donation/';
  static const String routename = 'FoodDonation';

  @override
  _FoodDonationState createState() => _FoodDonationState();
}

class _FoodDonationState extends State<FoodDonation> {
  List<Map<String, dynamic>> donations = [];
  bool isLoading = true;
  String? username;
  String? uniqueCode;
  List<String>? userGroups;

  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      uniqueCode = prefs.getString('uniqueCode');
      userGroups = prefs.getStringList('groups');
    });
    print('Loaded groups: $userGroups'); 

    if (username != null && uniqueCode != null) {
      _initializeDb();
    } else {
      setState(() {
        isLoading = false; // Stop loading if username or uniqueCode is not available
      });
    }
  }

  Future<void> _initializeDb() async {
    try {
      var db = await mongo.Db.create(MONGO_URL);
      await db.open();
      var collection = db.collection('Donors');
      var allDonations = await collection.find().toList();
      setState(() {
        donations = allDonations.map((doc) {
          // Convert ObjectId to String
          doc['_id'] = doc['_id'].toString();
          return Map<String, dynamic>.from(doc);
        }).toList();
        isLoading = false;
      });
      await db.close();
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  void _showAddFoodDialog() {
    if (username == null || uniqueCode == null) {
      // User is not logged in or uniqueCode is missing
      _showLoginDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AddFoodDialog(
          onSubmit: _addFoodDonation,
        );
      },
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Required'),
          content: Text('You need to login to add a food donation.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFoodDonation(Map<String, dynamic> donationData) async {
    try {
      var db = await mongo.Db.create(MONGO_URL);
      await db.open();
      var collection = db.collection('Donors');

      // Adding uniqueCode and username to the donation data
      donationData['uniqueCode'] = uniqueCode;
      donationData['name'] = username;

      // Inserting the donation map into the collection
      await collection.insertOne(donationData);
      await db.close();

      // Refresh the list to display new data
      _initializeDb();
    } catch (e) {
      print('Error adding donation: $e');
    }
  }

  Future<void> _deleteFoodDonation(String id) async {
    try {
      var db = await mongo.Db.create(MONGO_URL);
      await db.open();
      var collection = db.collection('Donors');

      var selector = mongo.where.id(mongo.ObjectId.fromHexString(id.substring(10, 34)));

      await collection.remove(selector);
      await db.close();

      // Refresh the list to remove deleted item
      _initializeDb();
    } catch (e) {
      print('Error deleting donation: $e');
    }
  }

  Future<void> _showDeleteDialog(String id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Donation'),
          content: Text('Are you sure you want to delete this donation?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFoodDonation(id);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showContactDialog(String contact) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Contact Information'),
          content: Text('Would you like to call $contact?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchCaller(contact);
              },
              child: Text('Call'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchCaller(String contact) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: contact,
    );
    await launchUrl(launchUri);
  }

  void _checkEligibilityAndShowContact(String contact, List<String> donationGroups) {
    print('Donation groups: $donationGroups'); 

    bool isEligible = userGroups != null &&
        donationGroups.any((group) => userGroups!.contains(group));

    print('Is eligible: $isEligible'); 

    if (isEligible) {
      _showContactDialog(contact);
    } else {
      _showNotEligibleDialog();
    }
  }

  Future<void> _showNotEligibleDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Not Eligible'),
          content: Text('You are not eligible to contact this donor.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _calorieController.dispose();
    _expiryDateController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FoodDonation.routename),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : donations.isEmpty
              ? Center(child: Text("Login to See the List!"))
              : ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _generateRandomColor(),
                        ),
                        title: Text(donation['name']),
                        subtitle: Text('Food: ${donation['food']} - Calories: ${donation['calories']} - Expiry date: ${donation['expiryDate']}'),
                        onTap: () {
                          if (donation['uniqueCode'] == uniqueCode) {
                            _showDeleteDialog(donation['_id']);
                          } else {
                            _checkEligibilityAndShowContact(donation['contact'], List<String>.from(donation['groups']));
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: Icon(Icons.add),
        tooltip: 'Request for Donation',
      ),
    );
  }
}

class AddFoodDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  AddFoodDialog({required this.onSubmit});

  @override
  _AddFoodDialogState createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  DateTime? _selectedDate;

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
    _foodNameController.dispose();
    _calorieController.dispose();
    _expiryDateController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _expiryDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _submit() {
    Map<String, dynamic> donationData = {
      'food': _foodNameController.text,
      'calories': _calorieController.text,
      'expiryDate': _expiryDateController.text,
      'contact': _contactController.text,
      'groups': _selectedGroups.entries.where((entry) => entry.value).map((entry) => entry.key).toList(),
    };
    widget.onSubmit(donationData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add a Food Donation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _foodNameController,
              decoration: InputDecoration(hintText: "Enter food name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _calorieController,
              decoration: InputDecoration(hintText: "Enter calorie amount"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(
                hintText: "Enter expiry date",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(hintText: "Enter your phone number or Email"),
            ),
            SizedBox(height: 10),
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
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _submit,
          child: Text('Submit'),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => LoginPage(),
      FoodDonation.route: (context) => FoodDonation(),
    },
  ));
}
