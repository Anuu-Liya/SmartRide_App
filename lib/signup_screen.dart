import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      // 1. Firebase Auth හරහා User සාදාගැනීම
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. සාදාගත් User ගේ UID එක යටතේ Firestore එකේ දත්ත සේව් කිරීම
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'vehicleModel': _vehicleModelController.text.trim(),
        'vehicleNumber': _vehicleNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'fuelLevel': 0, // Default values
        'nextService': 'Not Set',
      });

      if (!mounted) return;
      Navigator.pop(context); // ආපහු Login එකට යන්න
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text("Create Account", style: TextStyle(color: Colors.green))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name", labelStyle: TextStyle(color: Colors.green))),
            const SizedBox(height: 15),
            TextField(controller: _vehicleModelController, decoration: const InputDecoration(labelText: "Vehicle Model (e.g. Toyota Vitz)", labelStyle: TextStyle(color: Colors.green))),
            const SizedBox(height: 15),
            TextField(controller: _vehicleNumberController, decoration: const InputDecoration(labelText: "Vehicle Number (e.g. NW CAD 8865)", labelStyle: TextStyle(color: Colors.green))),
            const SizedBox(height: 15),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", labelStyle: TextStyle(color: Colors.green))),
            const SizedBox(height: 15),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.green))),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.green)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, minimumSize: const Size(double.infinity, 50)),
              onPressed: _signup,
              child: const Text("SIGN UP", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}