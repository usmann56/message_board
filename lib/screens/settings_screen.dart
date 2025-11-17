import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './profile_screen.dart';
import '../components/app_drawer.dart';
import './change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    await _auth.signOut();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));

    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      drawer: AppDrawer(),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.person),
            title: const Text("Edit Personal Info"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text("Log Out"),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
