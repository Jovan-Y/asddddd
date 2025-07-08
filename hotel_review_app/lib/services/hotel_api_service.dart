
import 'dart:convert';
import 'package:http/http.dart' as http;

class HotelApiService {
  Future<List<Map<String, String>>> searchHotels(String query, String apiKey) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=lodging&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'OK') {
          print('Google Places API Error: ${data['status']}');
          if (data['error_message'] != null) {
            print('Error Message: ${data['error_message']}');
          }
          return [];
        }

        final predictions = data['predictions'] as List;
        return predictions.map((p) {
          return {
            'description': p['description'] as String,
            'place_id': p['place_id'] as String,
          };
        }).toList();
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception while fetching hotels: $e");
    }
    return [];
  }
}