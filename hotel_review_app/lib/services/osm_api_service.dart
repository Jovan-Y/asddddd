// lib/services/osm_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OsmApiService {
  // Nominatim API tidak memerlukan API Key
  final String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  Future<List<Map<String, String>>> searchHotels(String query) async {
    // Kita tambahkan 'hotel' dalam query untuk mempersempit hasil
    final String fullQuery = 'hotel in $query';
    final url = Uri.parse(
        '$_baseUrl?q=$fullQuery&format=json&addressdetails=1&limit=10');

    try {
      final response = await http.get(
        url,
        // Penting: Nominatim memerlukan User-Agent yang jelas
        headers: {'User-Agent': 'com.example.hotel_review_app'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        List<Map<String, String>> suggestions = [];

        for (var place in data) {
          // Pastikan data memiliki 'display_name' dan 'osm_id'
          if (place['display_name'] != null && place['osm_id'] != null) {
            suggestions.add({
              'description': place['display_name'] as String,
              // Kita ganti 'place_id' dengan 'osm_id' yang unik dari OpenStreetMap
              'place_id': place['osm_id'].toString(),
            });
          }
        }
        return suggestions;
      } else {
        print('Nominatim API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Exception while fetching from OSM: $e");
      return [];
    }
  }
}