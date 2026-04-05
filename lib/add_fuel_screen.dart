import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFuelScreen extends StatefulWidget {
  const AddFuelScreen({super.key});

  @override
  State<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends State<AddFuelScreen> {
  final _fuelController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updateFuel() async {
    if (_fuelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter fuel percentage")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final vehicleQuery = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('userId', isEqualTo: user?.uid)
          .get();

      if (vehicleQuery.docs.isNotEmpty) {
        String docId = vehicleQuery.docs.first.id;
        await FirebaseFirestore.instance.collection('vehicles').doc(docId).update({
          'fuelLevel': "${_fuelController.text}%",
        });

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fuel Level Updated!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Add Fuel Record", style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update Fuel Level",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Enter the current fuel percentage of your vehicle.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: _fuelController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Fuel Percentage (0-100)",
                labelStyle: const TextStyle(color: Colors.green),
                prefixIcon: const Icon(Icons.local_gas_station, color: Colors.green),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.withValues(alpha: 0.5)),
                ),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _updateFuel,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("UPDATE LEVEL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}