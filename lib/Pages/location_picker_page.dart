// // location_picker_page.dart
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';

// class LocationPickerPage extends StatefulWidget {
//   @override
//   _LocationPickerPageState createState() => _LocationPickerPageState();
// }

// class _LocationPickerPageState extends State<LocationPickerPage> {
//   LatLng? _pickedLocation;
//   String _address = 'Move the pin to select a location';

//   void _onTap(LatLng position) async {
//     setState(() {
//       _pickedLocation = position;
//     });

//     // Get address from coordinates
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );
//     if (placemarks.isNotEmpty) {
//       final place = placemarks.first;
//       setState(() {
//         _address =
//             '${place.name}, ${place.locality}, ${place.administrativeArea}';
//       });
//     }
//   }

//   void _confirmLocation() {
//     if (_pickedLocation != null) {
//       Navigator.pop(context, _address);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Pick Location')),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(11.5621, 104.8885), // Example location
//               zoom: 14,
//             ),
//             onTap: _onTap,
//             markers: _pickedLocation != null
//                 ? {
//                     Marker(
//                       markerId: MarkerId('picked'),
//                       position: _pickedLocation!,
//                     )
//                   }
//                 : {},
//           ),
//           Positioned(
//             bottom: 20,
//             left: 16,
//             right: 16,
//             child: Column(
//               children: [
//                 Text(_address, textAlign: TextAlign.center),
//                 SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed: _confirmLocation,
//                   child: Text('Confirm Location'),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
