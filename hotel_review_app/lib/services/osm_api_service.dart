
import 'dart:convert';
import 'package:http/http.dart' as http;

class OsmApiService {
  final String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  Future<List<Map<String, String>>> searchHotels(String query) async {
    final String fullQuery = 'hotel in $query';
    final url = Uri.parse(
        '$_baseUrl?q=$fullQuery&format=json&addressdetails=1&limit=10');

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.hotel_review_app'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        List<Map<String, String>> suggestions = [];

        for (var place in data) {
          if (place['display_name'] != null && place['osm_id'] != null) {
            suggestions.add({
              'description': place['display_name'] as String,
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