import 'package:flutter/material.dart';

class GarageFinderScreen extends StatefulWidget {
  const GarageFinderScreen({super.key});

  @override
  State<GarageFinderScreen> createState() => _GarageFinderScreenState();
}

class _GarageFinderScreenState extends State<GarageFinderScreen> {
  // ගරාජ් දත්ත ලැයිස්තුව
  final List<Map<String, dynamic>> garages = [
    {"name": "City Auto Care", "location": "Kandy", "dist": "1.2 km", "rating": 4.8, "img": "https://via.placeholder.com/150"},
    {"name": "Lanka Hybrid Motors", "location": "Peradeniya", "dist": "3.5 km", "rating": 4.5, "img": "https://via.placeholder.com/150"},
    {"name": "Express Service Hub", "location": "Katugastota", "dist": "5.0 km", "rating": 4.2, "img": "https://via.placeholder.com/150"},
    {"name": "Smart Wheels Garage", "location": "Gelioya", "dist": "7.2 km", "rating": 4.7, "img": "https://via.placeholder.com/150"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Find a Garage",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by location or name...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip("All", isSelected: true),
                _buildFilterChip("Nearby"),
                _buildFilterChip("Top Rated"),
                _buildFilterChip("24 Hours"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. Garage List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: garages.length,
              itemBuilder: (context, index) {
                final garage = garages[index];
                return _buildGarageCard(garage);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        backgroundColor: isSelected ? Colors.green : const Color(0xFF1E1E1E),
        label: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildGarageCard(Map<String, dynamic> garage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Garage Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(garage['img'], width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(garage['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(garage['location'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green, size: 14),
                    Text(" ${garage['dist']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 15),
                    const Icon(Icons.star, color: Colors.yellow, size: 14),
                    Text(" ${garage['rating']}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          // Action Button
          IconButton(
            onPressed: () {
              // ගරාජ් එකේ විස්තර පෙන්වන පේජ් එකට හෝ බුකින් පේජ් එකට යාමට
            },
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.green, size: 18),
          ),
        ],
      ),
    );
  }
}