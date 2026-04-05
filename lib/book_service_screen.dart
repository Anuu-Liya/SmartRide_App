import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _vehicleController = TextEditingController(text: "Toyota Vitz - NW CAD 8865");
  final _contactController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // පේජ් එකට එද්දීම ප්‍රොෆයිල් එකේ නම්බර් එක ලෝඩ් කරනවා
  }

  // Firestore එකෙන් යූසර්ගේ ප්‍රොෆයිල් විස්තර ලබා ගැනීම
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('users') // ඔබේ collection නම 'users' බව තහවුරු කරගන්න
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            // Firestore එකේ ෆෝන් නම්බර් එක සේව් කරලා තියෙන field නම (phone) මෙතනට දෙන්න
            _contactController.text = userDoc.data()!['phone'] ?? "";
          });
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
  }

  Future<void> _bookNow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter contact number"), backgroundColor: Colors.red),
      );
      return;
    }

    // Appointment එක සේව් කිරීම
    await FirebaseFirestore.instance.collection('appointments').add({
      'userId': user?.uid,
      'vehicle': _vehicleController.text,
      'contact': _contactController.text,
      'note': _noteController.text,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'time': _selectedTime.format(context),
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Confirmed!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Book a Service",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Vehicle Details"),
            _buildDarkField(_vehicleController, Icons.directions_car, enabled: false),

            const SizedBox(height: 20),
            _buildLabel("Appointment Schedule"),

            // Date Picker Field
            _buildPickerTile(
              icon: Icons.calendar_month,
              text: "Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),

            const SizedBox(height: 10),

            // Time Picker Field
            _buildPickerTile(
              icon: Icons.access_time,
              text: "Time: ${_selectedTime.format(context)}",
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),

            const SizedBox(height: 20),
            _buildLabel("Contact Information"),
            _buildDarkField(_contactController, Icons.phone, hint: "Phone Number", keyboardType: TextInputType.phone),

            const SizedBox(height: 20),
            _buildLabel("Special Notes (Optional)"),
            _buildDarkField(_noteController, Icons.note_add, hint: "e.g., Brake check, Oil change", maxLines: 4),

            const SizedBox(height: 40),

            // Confirm Booking Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green color from your image
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _bookNow,
                child: const Text("CONFIRM BOOKING",
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildDarkField(TextEditingController controller, IconData icon, {String? hint, bool enabled = true, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.green),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPickerTile({required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.yellow, size: 24),
            const SizedBox(width: 15),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}