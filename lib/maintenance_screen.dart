import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // කැමරාවෙන් හෝ ගැලරියෙන් ඡායාරූපයක් ලබා ගැනීම
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (!mounted) return;
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // මෙතනදී පසුව අපිට පුළුවන් මේ image එක Firebase වලට upload කරලා garage එකට share කරන්න
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo captured! Sharing with nearby garages...")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Maintenance & Emergency",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Maintenance Tips",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildTipCard("Engine Oil", "Change every 5,000-10,000 km.", Icons.oil_barrel),
            _buildTipCard("Tire Pressure", "Check pressure every two weeks.", Icons.speed),

            const SizedBox(height: 30),
            const Text("Emergency SOS",
                style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // SOS Button
            _buildEmergencyButton(),

            const SizedBox(height: 25),
            const Text("Report Vehicle Damage",
                style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Take a photo of the damage to share with mechanics.",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 15),

            // Damage Photo Section
            _buildPhotoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Emergency Signal Sent!"), backgroundColor: Colors.red),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 2),
        ),
        child: const Column(
          children: [
            Icon(Icons.sos, color: Colors.redAccent, size: 50),
            Text("PRESS FOR HELP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        if (_image != null)
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black),
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.black),
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}