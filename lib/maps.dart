import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapsPage(),
    );
  }
}

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  LatLng? _initialPosition;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  final double _zoomLevel = 13.0;
  bool _isLocationSet = false;
  final Set<Marker> _markers = {};

  // Initialize Firebase Database reference
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    _getDeviceLocation();
  }

  Future<void> _getDeviceLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _currentPosition = _initialPosition;
        _isLocationSet = true;
        _updateMarkers();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _searchLocation() async {
    String searchQuery = _searchController.text;
    if (searchQuery.isNotEmpty) {
      List<Location> locations = await locationFromAddress(searchQuery);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _initialPosition = LatLng(
            location.latitude,
            location.longitude,
          );
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _initialPosition!,
                zoom: _zoomLevel,
              ),
            ),
          );
        });
      }
    }
  }

  void _moveToCurrentPosition() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateZoom();
      });
    }
  }

  void _updateZoom() {
    if (_currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: _zoomLevel,
          ),
        ),
      );
    }
  }

  Future<void> _addCustomMarker(
      String markerId, LatLng position, String imagePath) async {
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      imagePath,
    );

    _markers.add(Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: customIcon,
    ));
  }

  Future<void> _addCustomMetaMarker(
      String markerId, LatLng position, String title, String subTitle) async {
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/marker.png',
    );

    _markers.add(Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: subTitle),
      icon: customIcon,
      onTap: () {
        mapController.showMarkerInfoWindow(MarkerId(markerId));
      },
    ));
  }

  void _updateMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
      _addCustomMarker(
          'current', _currentPosition!, 'assets/images/marker_1.png');
    }

    // Listen to changes in the 'lokasi' node in Firebase
    _databaseReference.child('alat').onValue.listen((event) {
      // Get the snapshot of the data
      DataSnapshot snapshot = event.snapshot;

      // Check if the snapshot has data
      if (snapshot.value != null) {
        // Clear existing markers before adding new ones
        _markers.clear();

        // Convert Object? to Map<dynamic, dynamic> using 'as'
        Map<dynamic, dynamic>? locationsData =
            snapshot.value as Map<dynamic, dynamic>?;

        // Check if locationsData is not null
        if (locationsData != null) {
          // Loop through the data to add markers
          locationsData.forEach((key, value) {
            double lat = value['lat'];
            double lng = value['lng'];
            String markerId = 'meta $key';
            String title = value['title'];
            String subTitle = value['sub_title'];
            _addCustomMetaMarker(markerId, LatLng(lat, lng), title, subTitle);
          });

          // Add marker for user's location
          if (_currentPosition != null) {
            _addCustomMarker(
                'user', _currentPosition!, 'assets/images/marker_1.png');
          }

          // Update the map to reflect the changes
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search Location',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _initialPosition != null
              ? GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition!,
                    zoom: _zoomLevel,
                  ),
                  markers: _markers,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
          Positioned(
            bottom: 120,
            right: 16,
            child: FloatingActionButton(
              child: const Icon(Icons.my_location, color: Colors.white),
              backgroundColor: const Color.fromRGBO(74, 172, 79, 1),
              onPressed: _isLocationSet ? _moveToCurrentPosition : null,
            ),
          ),
        ],
      ),
    );
  }
}
