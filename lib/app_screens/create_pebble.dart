import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:exif/exif.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CreatePebble extends StatefulWidget {
  const CreatePebble({Key? key}) : super(key: key);

  @override
  _CreatePebbleState createState() => _CreatePebbleState();
}

class _CreatePebbleState extends State<CreatePebble> with OSMMixinObserver {
  File? _selectedImage1;
  File? _selectedImage2;
  Uint8List? webImage1;
  Uint8List? webImage2;

  GeoPoint _pebblePhotoLocation = GeoPoint(latitude: 50.06841688370118, longitude: 19.941180855116613);
  GeoPoint _pebbleSelectedLocation = GeoPoint(latitude: 50.06841688370118, longitude: 19.941180855116613);
  late MapController _mapController;
  bool isGeoEXIF = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController.withPosition(initPosition: _pebbleSelectedLocation);
    _mapController.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      _mapController.setZoom(zoomLevel: isGeoEXIF ? 19 : 3);
      if (isGeoEXIF) {
        _mapController.moveTo(_pebbleSelectedLocation, animate: false);
      }
    }
  }

  @override
  void onRegionChanged(Region region) {
    super.onRegionChanged(region);
    _updateSelectedLocation();
  }

  void _updateSelectedLocation() async {
    GeoPoint center = await _mapController.centerMap;
    setState(() {
      _pebbleSelectedLocation = center;
    });
  }

  Widget _buildMap(double width, double height) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          children: [
            SizedBox(
              width: width,
              height: height,
              child: OSMFlutter(
                controller: _mapController,
                osmOption: OSMOption(
                  zoomOption: ZoomOption(
                    initZoom: 6,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: (height / 2) - 28,
              left: (width / 2) - 28,
              child: Icon(Icons.circle_outlined, color: Colors.lightGreen, size: 56),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: PointerInterceptor(
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: () async => await _mapController.zoomIn(),
                      mini: true,
                      backgroundColor: Colors.lightGreen,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.add),
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: () async => await _mapController.zoomOut(),
                      mini: true,
                      backgroundColor: Colors.lightGreen,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: PointerInterceptor(
                child: FloatingActionButton(
                  onPressed: () async {
                    _mapController.moveTo(_pebblePhotoLocation, animate: true);
                  },
                  mini: true,
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.center_focus_strong),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Create Pebble')),
        body: LayoutBuilder(
        builder: (context, constraints) {
      double availableWidth = constraints.maxWidth;
      double availableHeight = constraints.maxHeight;

      double rectangleWidth = availableWidth * 0.4;
      double rectangleHeight = rectangleWidth * 9 / 16;

      const double maxRectangleWidth = 450;
      const double maxRectangleHeight = 253.125;

      if (availableWidth > 600) {
        rectangleWidth = rectangleWidth.clamp(0, maxRectangleWidth);
        rectangleHeight = rectangleHeight.clamp(0, maxRectangleHeight);
      }
      return availableWidth > 600
          ? _buildWideLayout(rectangleWidth, rectangleHeight)
          : _buildNarrowLayout(availableHeight);
        },
        ),
    );
  }

  Widget _buildWideLayout(double rectangleWidth, double rectangleHeight) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRectangle(rectangleWidth, rectangleHeight, 'Image 1', () => _pickImage(1), _selectedImage1, webImage1),
            const SizedBox(width: 4),
            _buildRectangle(rectangleWidth, rectangleHeight, 'Image 2', () => _pickImage(2), _selectedImage2, webImage2),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage2 != null || webImage2 != null)
              _buildMap(rectangleWidth, rectangleHeight)
            else
              _buildRectangle(rectangleWidth, rectangleHeight, 'Map', () {}, null, null),
            const SizedBox(width: 4),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildRectangle(rectangleWidth, rectangleHeight / 2 - 7.5, 'Box 4', () {}, null, null),
                const SizedBox(height: 1),
                _buildRectangle(rectangleWidth, rectangleHeight / 2 - 7.5, 'Box 5', () {}, null, null),
              ],
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildNarrowLayout(double availableHeight) {
    double mobileRectangleHeight = availableHeight / 2;
    double mobileRectangleWidth = mobileRectangleHeight * 9 / 16;

    mobileRectangleHeight = mobileRectangleHeight < 240 ? 240 : mobileRectangleHeight;
    mobileRectangleWidth = mobileRectangleWidth < 135 ? 135 : mobileRectangleWidth;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRectangle(mobileRectangleHeight, mobileRectangleWidth, 'Image 1', () => _pickImage(1), _selectedImage1, webImage1),
            const SizedBox(height: 1),
            _buildRectangle(mobileRectangleHeight, mobileRectangleWidth, 'Image 2', () => _pickImage(2), _selectedImage2, webImage2),
            const SizedBox(height: 1),
            if (_selectedImage2 != null || webImage2 != null)
              _buildMap(mobileRectangleHeight, mobileRectangleWidth)
            else
              _buildRectangle(mobileRectangleHeight, mobileRectangleWidth, 'Map', () {}, null, null),
            const SizedBox(height: 1),
            _buildRectangle(mobileRectangleHeight, mobileRectangleWidth / 2.5, 'Box 4', () {}, null, null),
            const SizedBox(height: 1),
            _buildRectangle(mobileRectangleHeight, mobileRectangleWidth / 2.5, 'Box 5', () {}, null, null),
            const SizedBox(height: 15),
            _buildCreateButton(),
            const SizedBox(height: 75),
          ],
        ),
      ),
    );
  }

  Widget _buildRectangle(double width, double height, String label, VoidCallback onTap, File? imageFile, Uint8List? webImage) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: imageFile != null || webImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: kIsWeb
              ? (webImage != null
              ? Image.memory(webImage, fit: BoxFit.cover, width: width, height: height)
              : const Center(child: Text("No image")))
              : (imageFile != null
              ? Image.file(imageFile, fit: BoxFit.cover, width: width, height: height)
              : const Center(child: Text("No image"))),
        )
            : Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  ElevatedButton _buildCreateButton() {
    return ElevatedButton(
        onPressed: () {},
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.lightGreen,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
      child: const Text(
        'Create',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Future<void> _pickImage(int boxNumber) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        _updateSelectedImage(boxNumber, image.path, bytes);
      });
    } else {
      print('No image selected.');
    }
  }

  void _updateSelectedImage(int boxNumber, String imagePath, Uint8List bytes) {
    if (boxNumber == 1) {
      _selectedImage1 = File(imagePath);
      webImage1 = bytes;
    } else if (boxNumber == 2) {
      _selectedImage2 = File(imagePath);
      webImage2 = bytes;
      _extractExifData(kIsWeb ? bytes : imagePath);
    }
  }

  Future<void> _extractExifData(dynamic imagePathOrBytes) async {
    try {
      Map<String, IfdTag>? data;

      if (kIsWeb) {
        final bytes = imagePathOrBytes as Uint8List;
        data = await readExifFromBytes(bytes);
      } else {
        final bytes = await File(imagePathOrBytes).readAsBytes();
        data = await readExifFromBytes(bytes);
      }

      if (data.isNotEmpty) {
        _processExifData(data);
      } else {
        isGeoEXIF = false;
        print('No EXIF data found.');
      }
    } catch (e) {
      print('Error reading EXIF data: $e');
    }
  }

  void _processExifData(Map<String, IfdTag> data) {
    print('Photo taken on: ${data['EXIF DateTimeOriginal']}');
    List<double> latitude = _parseCoordinates(data['GPS GPSLatitude'].toString());
    List<double> longitude = _parseCoordinates(data['GPS GPSLongitude'].toString());
    _pebblePhotoLocation = GeoPoint(latitude: _DMSToDecimal(latitude), longitude: _DMSToDecimal(longitude));
    _pebbleSelectedLocation = _pebblePhotoLocation;
    isGeoEXIF = true;
  }

  List<double> _parseCoordinates(String coordinateString) {
    coordinateString = coordinateString.replaceAll('[', '').replaceAll(']', '');
    List<String> parts = coordinateString.split(', ');
    List<double> result = [];

    for (String part in parts) {
      if (part.contains('/')) {
        List<String> fractionParts = part.split('/');
        double fractionValue = double.parse(fractionParts[0]) / double.parse(fractionParts[1]);
        result.add(fractionValue);
      } else {
        result.add(double.parse(part));
      }
    }

    return result;
  }

  double _DMSToDecimal(List<double> position) {
    return position[0] + position[1] / 60 + position[2] / 3600;
  }
}


