import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_screen.dart';
import 'garage_finder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Smart Ride Dashboard",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.yellow),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>?;
          String name = userData?['name'] ?? "User";
          String vModel = userData?['vehicleModel'] ?? "No Vehicle Added";
          String vNumber = userData?['vehicleNumber'] ?? "No Number";

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Hello, $name!",
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Vehicle Info Card with Icons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: Colors.yellow, size: 50),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vModel, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(vNumber, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Status Row with Icons
                Row(
                  children: [
                    _buildStatCard("Fuel Level", "${userData?['fuelLevel'] ?? 0}%", Icons.local_gas_station, Colors.blue),
                    const SizedBox(width: 15),
                    _buildStatCard("Next Service", userData?['nextService'] ?? "Not Set", Icons.build_circle, Colors.orange),
                  ],
                ),

                const SizedBox(height: 20),

                // Monthly Cost Tile
                _buildActionTile("Monthly Fuel Cost", "${userData?['fuelCost'] ?? 0} LKR", Icons.account_balance_wallet, Colors.purple),

                const SizedBox(height: 30),
                const Text("Quick Actions", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Detailed Action List with Icons
                _buildQuickAction("Book a Service", Icons.calendar_month, () {}),
                _buildQuickAction("Add Fuel Record", Icons.add_circle, () {}),
                _buildQuickAction("Service History", Icons.history, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceScreen()));
                }),
                _buildQuickAction("Find Nearby Mechanic", Icons.location_on, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GarageFinderScreen()),
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        tileColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      ),
    );
  }
}