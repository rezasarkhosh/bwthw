import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  static const route = '/profilePage/';

  static const String routename = 'profilePage';

  Future<Map<String, String?>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'surname': prefs.getString('surname'),
      'email': prefs.getString('email'),
    };
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 

    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
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
        child: FutureBuilder<Map<String, String?>>(
          future: _getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!['name'] == null) {
              return Center(child: Text('No user data found'));
            } else {
              var userInfo = snapshot.data!;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/images/profile1.jpg'),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${userInfo['name']} ${userInfo['surname']}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      InfoCard(
                        icon: Icons.email,
                        text: userInfo['email']!,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.teal, 
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.teal.shade900,
          ),
        ),
      ),
    );
  }
}
