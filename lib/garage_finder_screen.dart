import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum GarageFilter { all, nearby, topRated, open24 }

class Garage {
  final String id;
  final String name;
  final String locationLabel;
  final LatLng location;
  final double rating;
  final bool open24;
  final String imageUrl;

  const Garage({
    required this.id,
    required this.name,
    required this.locationLabel,
    required this.location,
    required this.rating,
    required this.open24,
    required this.imageUrl,
  });
}

class GarageFinderScreen extends StatefulWidget {
  const GarageFinderScreen({super.key});

  @override
  State<GarageFinderScreen> createState() => _GarageFinderScreenState();
}

class _GarageFinderScreenState extends State<GarageFinderScreen> {
  final _searchController = TextEditingController();

  LatLng? _currentLatLng;
  bool _loadingLocation = true;
  String? _locationError;

  GarageFilter _filter = GarageFilter.all;

  static const double _nearbyKm = 5;
  static const double _topRatedThreshold = 4.5;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled.';
          _loadingLocation = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permission denied.';
          _loadingLocation = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission permanently denied. Enable it in Settings.';
          _loadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location: $e';
        _loadingLocation = false;
      });
    }
  }

  List<Garage> _garagesNear(LatLng center) {
    return [
      Garage(
        id: 'g1',
        name: 'City Auto Care',
        locationLabel: 'Nearby',
        location: LatLng(center.latitude + 0.004, center.longitude + 0.002),
        rating: 4.8,
        open24: true,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Garage(
        id: 'g2',
        name: 'Lanka Hybrid Motors',
        locationLabel: 'Nearby',
        location: LatLng(center.latitude - 0.006, center.longitude + 0.001),
        rating: 4.5,
        open24: false,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Garage(
        id: 'g3',
        name: 'Express Service Hub',
        locationLabel: 'Nearby',
        location: LatLng(center.latitude + 0.010, center.longitude - 0.008),
        rating: 4.2,
        open24: true,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Garage(
        id: 'g4',
        name: 'Smart Wheels Garage',
        locationLabel: 'Nearby',
        location: LatLng(center.latitude - 0.012, center.longitude - 0.010),
        rating: 4.7,
        open24: false,
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];
  }

  double? _distanceKm(LatLng from, LatLng to) {
    final meters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    return meters / 1000;
  }

  List<Garage> _applyFilters(List<Garage> garages) {
    final q = _searchController.text.trim().toLowerCase();

    Iterable<Garage> filtered = garages;

    if (q.isNotEmpty) {
      filtered = filtered.where(
        (g) => g.name.toLowerCase().contains(q) || g.locationLabel.toLowerCase().contains(q),
      );
    }

    if (_currentLatLng != null) {
      switch (_filter) {
        case GarageFilter.all:
          break;
        case GarageFilter.nearby:
          filtered = filtered.where((g) {
            final d = _distanceKm(_currentLatLng!, g.location);
            return d != null && d <= _nearbyKm;
          });
        case GarageFilter.topRated:
          filtered = filtered.where((g) => g.rating >= _topRatedThreshold);
        case GarageFilter.open24:
          filtered = filtered.where((g) => g.open24);
      }
    }

    return filtered.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _currentLatLng != null;
    final garages = hasLocation ? _garagesNear(_currentLatLng!) : const <Garage>[];
    final visibleGarages = _applyFilters(garages);

    final markers = <Marker>{};
    if (hasLocation) {
      markers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: _currentLatLng!,
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
      for (final garage in visibleGarages) {
        markers.add(
          Marker(
            markerId: MarkerId(garage.id),
            position: garage.location,
            infoWindow: InfoWindow(
              title: garage.name,
              snippet: 'Rating: ${garage.rating.toStringAsFixed(1)}',
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Find a Garage",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.green),
        actions: [
          IconButton(
            onPressed: _initLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Refresh location',
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
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
                _buildFilterChip("All", selected: _filter == GarageFilter.all, onTap: () => _setFilter(GarageFilter.all)),
                _buildFilterChip("Nearby", selected: _filter == GarageFilter.nearby, onTap: () => _setFilter(GarageFilter.nearby)),
                _buildFilterChip("Top Rated", selected: _filter == GarageFilter.topRated, onTap: () => _setFilter(GarageFilter.topRated)),
                _buildFilterChip("24 Hours", selected: _filter == GarageFilter.open24, onTap: () => _setFilter(GarageFilter.open24)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. Map Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 220,
                child: _loadingLocation
                    ? const Center(child: CircularProgressIndicator())
                    : _locationError != null
                        ? Container(
                            color: const Color(0xFF1E1E1E),
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: Text(
                              _locationError!,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentLatLng!,
                              zoom: 14,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            markers: markers,
                          ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 4. Garage List
          Expanded(
            child: hasLocation
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleGarages.length,
                    itemBuilder: (context, index) {
                      final garage = visibleGarages[index];
                      final d = _distanceKm(_currentLatLng!, garage.location);
                      return _buildGarageCard(garage, distanceKm: d);
                    },
                  )
                : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Enable location to find nearby garages on the map.',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _setFilter(GarageFilter next) {
    setState(() {
      _filter = next;
    });
  }

  Widget _buildFilterChip(String label, {required bool selected, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.green,
        backgroundColor: const Color(0xFF1E1E1E),
        label: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildGarageCard(Garage garage, {double? distanceKm}) {
    final distanceText = distanceKm == null ? '—' : '${distanceKm.toStringAsFixed(1)} km';
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
            child: Image.network(garage.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(garage.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(garage.locationLabel, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green, size: 14),
                    Text(" $distanceText", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 15),
                    const Icon(Icons.star, color: Colors.yellow, size: 14),
                    Text(" ${garage.rating}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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