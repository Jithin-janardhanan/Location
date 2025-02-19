// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class MapboxNavigation {
//   final String accessToken;
//   final MapboxMap mapboxMap;

//   MapboxNavigation({
//     required this.accessToken,
//     required this.mapboxMap,
//   });

//   Future<void> getDirectionsAndDraw({
//     required double startLat,
//     required double startLng,
//     required double endLat,
//     required double endLng,
//   }) async {
//     try {
//       // Get directions from Mapbox Directions API
//       final response = await _getDirections(
//         startLat: startLat,
//         startLng: startLng,
//         endLat: endLat,
//         endLng: endLng,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
        
//         // Extract route coordinates
//         final route = data['routes'][0]['geometry'];
//         final decodedRoute = await _decodePolyline(route);

//         // Create a line source and layer
//         await _createRouteLayer(decodedRoute);

//         // Adjust camera to show the entire route
//         await _fitBoundsToRoute(
//           Position(startLng, startLat),
//           Position(endLng, endLat),
//         );
//       } else {
//         throw Exception('Failed to get directions');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<http.Response> _getDirections({
//     required double startLat,
//     required double startLng,
//     required double endLat,
//     required double endLng,
//   }) async {
//     final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/'
//         '$startLng,$startLat;$endLng,$endLat'
//         '?geometries=polyline6&overview=full&access_token=$accessToken';

//     return await http.get(Uri.parse(url));
//   }

//   Future<List<Position>> _decodePolyline(String encodedPolyline) async {
//     List<Position> decodedCoords = [];
    
//     // Implementation of polyline decoding algorithm
//     // You can use a package like 'polyline' or implement the algorithm
//     // This is a simplified version
//     // TODO: Implement full polyline decoding

//     return decodedCoords;
//   }

//   Future<void> _createRouteLayer(List<Position> coordinates) async {
//     // Create a GeoJSON source for the route
//     final sourceProperties = GeoJSONSourceProperties(
//       data: {
//         "type": "Feature",
//         "properties": {},
//         "geometry": {
//           "type": "LineString",
//           "coordinates": coordinates
//               .map((coord) => [coord.lng, coord.lat])
//               .toList(),
//         }
//       },
//     );

//     // Add source to the map
//     await mapboxMap.style.addSource(
//       "route-source",
//       GeoJSONSource(properties: sourceProperties),
//     );

//     // Create a line layer to display the route
//     final lineLayerProperties = LineLayerProperties(
//       lineColor: Colors.blue.value,
//       lineWidth: 5.0,
//       lineCap: LineCap.ROUND,
//       lineJoin: LineJoin.ROUND,
//     );

//     // Add the line layer to the map
//     await mapboxMap.style.addLayer(
//       "route-layer",
//       LineLayer(
//         id: "route-layer",
//         sourceId: "route-source",
//         properties: lineLayerProperties,
//       ),
//     );
//   }

//   Future<void> _fitBoundsToRoute(Position start, Position end) async {
//     final bounds = CoordinateBounds(
//       southwest: start,
//       northeast: end,
//       infiniteBounds: false,
//     );

//     await mapboxMap.setCamera(
//       CameraOptions(
//         bounds: bounds,
//         padding: MbxEdgeInsets(
//           top: 50.0,
//           left: 50.0,
//           bottom: 50.0,
//           right: 50.0,
//         ),
//       ),
//     );
//   }

//   Future<void> clearRoute() async {
//     try {
//       // Remove the route layer and source
//       if (await mapboxMap.style.layerExists("route-layer")) {
//         await mapboxMap.style.removeLayer("route-layer");
//       }
//       if (await mapboxMap.style.sourceExists("route-source")) {
//         await mapboxMap.style.removeSource("route-source");
//       }
//     } catch (e) {
//       print('Error clearing route: $e');
//     }
//   }
// }