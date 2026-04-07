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
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final vehicleModel = _vehicleModelController.text.trim();
    final vehicleNumber = _vehicleNumberController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name, email, and password.')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    UserCredential? userCredential;
    try {
      // 1. Firebase Auth හරහා User සාදාගැනීම
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      final code = e.code;

      String message = e.message ?? 'Signup failed.';
      if (code == 'email-already-in-use') {
        message = 'That email is already in use.';
      } else if (code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (code == 'operation-not-allowed') {
        message = 'Email/Password sign-in is disabled in Firebase Console.';
      } else if (code == 'network-request-failed') {
        message = 'Network error. Check your connection and try again.';
      } else if (code == 'internal-error') {
        message = 'Internal error from Firebase. If it says "API key not valid", your Firebase API key restrictions/config are wrong.';
      } else if (code == 'invalid-api-key' || code == 'api-key-not-valid' || code == 'app-not-authorized') {
        message = 'Firebase API key/app authorization issue ($code). Check Firebase config.';
      }

      message = '($code) $message';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
      return;
    }

    final uid = userCredential.user?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed: missing user id.')),
      );
      return;
    }

    String? warning;

    try {
      // 2. සාදාගත් User ගේ UID එක යටතේ Firestore එකේ දත්ත සේව් කිරීම
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'fullName': name,
        'vehicleModel': vehicleModel,
        'vehicleNumber': vehicleNumber,
        'email': email,
        'fuelLevel': 0, // Default values
        'nextService': 'Not Set',
      });
    } on FirebaseException catch (e) {
      // Account is created, but profile save failed (most commonly Firestore rules).
      warning = 'Account created, but saving your profile failed (${e.code}).';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$warning Please check Firestore rules/permissions.')),
      );
    } catch (e) {
      warning = 'Account created, but saving your profile failed.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created, but profile save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;
    Navigator.pop(context, warning ?? 'Account created. Please log in.');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
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