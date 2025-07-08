
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  Future<Position?> getCurrentLocation() async {
  }


  Future<String?> getAddressFromCoordinates(double lat, double lon, String apiKey) async {

    if (!kIsWeb) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final place = placemarks[0];
          return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
        }
      } catch (e) {
        print("Geocoding package error: $e");
      }
      return null;
    }

    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          print('Google Geocoding API Error: ${data['status']}');
        }
      }
    } catch (e) {
      print("HTTP Geocoding error: $e");
    }
    return 'Alamat tidak ditemukan';
  }
}