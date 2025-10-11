import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.deepPurple),
                SizedBox(height: 20),
                Text("Login",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/budget');
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Login"),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Text("Don't have an account? Sign Up"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
