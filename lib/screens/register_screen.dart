import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/room_selection_screen.dart';

class AuthTabsScreen extends StatelessWidget {
  final FirebaseAuth auth;

  const AuthTabsScreen({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Authentication'),
          bottom: TabBar(
            tabs: [
              Tab(text: "Register"),
              Tab(text: "Login"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RegisterEmailSection(auth: auth),
            EmailPasswordForm(auth: auth),
          ],
        ),
      ),
    );
  }
}

class RegisterEmailSection extends StatefulWidget {
  RegisterEmailSection({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  _RegisterEmailSectionState createState() => _RegisterEmailSectionState();
}

class _RegisterEmailSectionState extends State<RegisterEmailSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _success = false;
  bool _initialState = true;
  String? _message;

  Future<void> _selectDOB() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  void _register() async {
    try {
      UserCredential result = await widget.auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save additional profile info to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(result.user!.uid)
          .set({
            "firstName": _firstName.text.trim(),
            "lastName": _lastName.text.trim(),
            "dob": _dobController.text,
            "email": _emailController.text.trim(),
          });

      setState(() {
        _success = true;
        _initialState = false;
        _message = "Successfully registered ${_emailController.text}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration successful! Welcome ${_firstName.text} 😊',
          ),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainRoomScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      if (e.code == 'invalid-email') {
        errorMsg = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Password must be at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        errorMsg = 'This email is already registered.';
      } else {
        errorMsg = 'Registration failed: ${e.message}';
      }

      setState(() {
        _success = false;
        _initialState = false;
        _message = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text("Create Account", style: TextStyle(fontSize: 18)),

            TextFormField(
              controller: _firstName,
              decoration: InputDecoration(labelText: "First Name"),
              validator: (value) {
                if (value!.isEmpty) return "Please enter first name";
                return null;
              },
            ),

            TextFormField(
              controller: _lastName,
              decoration: InputDecoration(labelText: "Last Name"),
              validator: (value) {
                if (value!.isEmpty) return "Please enter last name";
                return null;
              },
            ),

            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDOB,
            ),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              validator: (value) {
                if (value!.isEmpty) return "Please enter email";
                return null;
              },
            ),

            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) return "Please enter password";
                return null;
              },
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _register();
                }
              },
              child: Text("Register"),
            ),

            SizedBox(height: 20),
            Text(
              _initialState ? "" : _message ?? "Registration failed",
              style: TextStyle(color: _success ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailPasswordForm extends StatefulWidget {
  EmailPasswordForm({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;
  @override
  _EmailPasswordFormState createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = false;
  bool _initialState = true;
  String _userEmail = '';
  void _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await widget.auth
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      setState(() {
        _success = true;
        _userEmail = _emailController.text;
        _initialState = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainRoomScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      if (e.code == 'invalid-email') {
        errorMsg = 'Please enter a valid email address (e.g., test@gmail.com).';
      } else if (e.code == 'user-not-found') {
        errorMsg = 'No account found for this email.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Incorrect password. Please try again.';
      } else if (e.code == 'user-disabled') {
        errorMsg = 'This account has been disabled.';
      } else {
        errorMsg = 'Sign in failed: ${e.message}';
      }

      setState(() {
        _success = false;
        _initialState = false;
        _userEmail = errorMsg;
      });
    } catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
        _userEmail = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                'Sign in with email and password',
                style: TextStyle(fontSize: 15),
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signInWithEmailAndPassword();
                  }
                },
                child: Text('Submit'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _initialState
                    ? ''
                    : _success
                    ? 'Successfully signed in $_userEmail'
                    : _userEmail,
                style: TextStyle(color: _success ? Colors.green : Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
