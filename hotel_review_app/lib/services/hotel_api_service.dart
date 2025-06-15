// lib/services/hotel_api_service.dart
class HotelApiService {
  // Dalam implementasi nyata, ini akan mengambil data hotel dari API eksternal.
  // Untuk demo, kita akan menggunakan data dummy atau membiarkan pengguna memasukkan nama hotel.

  // Contoh data dummy hotel
  static const List<String> dummyHotels = [
    'Hotel Majapahit Surabaya',
    'The Dharmawangsa Jakarta',
    'Ayana Resort and Spa Bali',
    'Plataran Borobudur Resort & Spa',
    'The Ritz-Carlton Jakarta, Pacific Place',
  ];

  Future<List<String>> searchHotels(String query) async {
    // Simulasi penundaan API
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.isEmpty) {
      return dummyHotels;
    }
    return dummyHotels
        .where((hotel) => hotel.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}