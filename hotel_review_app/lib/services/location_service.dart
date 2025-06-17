// lib/services/location_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Fungsi getCurrentLocation tetap sama
  Future<Position?> getCurrentLocation() async {
    // ... (kode tidak berubah)
  }

  // --- FUNGSI DIPERBARUI UNTUK MENANGANI WEB SECARA KHUSUS ---
  Future<String?> getAddressFromCoordinates(double lat, double lon, String apiKey) async {
    // Jika platformnya BUKAN web, gunakan paket geocoding seperti biasa
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

    // --- JIKA PLATFORM ADALAH WEB, GUNAKAN HTTP API ---
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Ambil alamat yang paling bagus formatnya dari hasil pertama
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