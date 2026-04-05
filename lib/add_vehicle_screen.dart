import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveVehicle() async {
    if (_nameController.text.isEmpty || _numberController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('vehicles').add({
        'userId': user?.uid,
        'vehicleName': _nameController.text.trim(),
        'plateNumber': _numberController.text.trim(),
        'fuelLevel': 100, // Default 100%
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vehicle Added Successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Add Vehicle"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Vehicle Name (e.g. Toyota Sedan)", labelStyle: TextStyle(color: Colors.green)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _numberController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Number Plate (e.g. WP CAB-1234)", labelStyle: TextStyle(color: Colors.green)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                onPressed: _isLoading ? null : _saveVehicle,
                child: _isLoading ? const CircularProgressIndicator() : const Text("SAVE VEHICLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}