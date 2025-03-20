import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> with OSMMixinObserver {
  late MapController _mapController;
  GeoPoint _selectedLocation = GeoPoint(latitude: 47.4358055, longitude: 8.4737324);

  @override
  void initState() {
    super.initState();
    _mapController = MapController.withPosition(
      initPosition: _selectedLocation,
    );
    _mapController.addObserver(this);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      // Optionally, you can perform actions when the map is ready
    }
  }

  @override
  void onRegionChanged(Region region) {
    super.onRegionChanged(region);
    // Update the selected location based on the center of the map
    _updateSelectedLocation();
  }

  void _updateSelectedLocation() async {
    GeoPoint center = await _mapController.centerMap;
    setState(() {
      _selectedLocation = center;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Picker"),
      ),
      body: Stack(
        children: [
          OSMFlutter(
            controller: _mapController,
            osmOption: OSMOption(
              userTrackingOption: UserTrackingOption(
                enableTracking: true,
                unFollowUser: false,
              ),
              zoomOption: ZoomOption(
                initZoom: 12,
                minZoomLevel: 3,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),

            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 28,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: Icon(
              Icons.location_pin,
              color: Colors.blue,
              size: 56,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                // Handle the selected location
                print("Selected Location: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}");
              },
              child: Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}
