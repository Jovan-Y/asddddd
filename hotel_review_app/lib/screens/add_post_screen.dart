// lib/screens/add_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_review_app/models/post.dart';
import 'package:hotel_review_app/services/firestore_service.dart';
import 'package:hotel_review_app/services/location_service.dart';
import 'package:hotel_review_app/services/hotel_api_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _hotelController = TextEditingController();
  bool _isLoading = false;

  double _rating = 3.0;
  String? _locationAddress;
  String? _selectedHotelName;
  String? _selectedPlaceId;
  List<Map<String, String>> _hotelSuggestions = [];

  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final HotelApiService _hotelApiService = HotelApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- KUNCI API TELAH DIGANTI ---
  final String _apiKey = "AIzaSyD2K3_YrJPCZvpDOVfU6idJe66nUMIOsYg";

 Future<void> _getCurrentLocation() async {
  setState(() => _isLoading = true);
  try {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final address = await _locationService.getAddressFromCoordinates(
          position.latitude, position.longitude, _apiKey);
      if (mounted) {
        setState(() {
          _locationAddress = address;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi berhasil diambil!')),
        );
      }
    }
  } catch (e) {
    // --- PERBAIKAN DI SINI ---
    // Tampilkan pesan error kepada pengguna melalui SnackBar.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    print("Error getting location: $e"); // Tetap cetak di konsol untuk debug
    // --- AKHIR PERBAIKAN ---
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Future<void> _postReview() async {
    if (_statusController.text.isEmpty || _selectedPlaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan dan nama hotel harus diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final post = Post(
      id: '',
      userId: user.uid,
      userName: user.displayName,
      statusText: _statusController.text,
      timestamp: DateTime.now(),
      rating: _rating,
      locationAddress: _locationAddress,
      hotelName: _selectedHotelName,
      hotelPlaceId: _selectedPlaceId,
    );

    try {
      await _firestoreService.addPost(post);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error posting review: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _searchHotels(String query) async {
    if (query.length < 3) {
      if (mounted) {
        setState(() => _hotelSuggestions = []);
      }
      return;
    }
    final results = await _hotelApiService.searchHotels(query, _apiKey);
    if (mounted) {
      setState(() => _hotelSuggestions = results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Ulasan Baru')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _hotelController,
                    decoration: InputDecoration(
                      hintText: 'Cari Nama Hotel...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.hotel),
                    ),
                    onChanged: _searchHotels,
                  ),
                  if (_hotelSuggestions.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _hotelSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _hotelSuggestions[index];
                          return ListTile(
                            title: Text(suggestion['description']!),
                            onTap: () {
                              setState(() {
                                _selectedHotelName =
                                    suggestion['description']!;
                                _selectedPlaceId = suggestion['place_id']!;
                                _hotelController.text = _selectedHotelName!;
                                _hotelSuggestions = [];
                              });
                              FocusScope.of(context).unfocus();
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text('Beri Rating Anda:',
                      style: Theme.of(context).textTheme.titleMedium),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _statusController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Bagikan pengalaman hotel Anda...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.location_on),
                    label: Text(_locationAddress == null
                        ? 'Tambahkan Lokasi Saat Ini'
                        : 'Lokasi Ditambahkan'),
                  ),
                  if (_locationAddress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_locationAddress!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _postReview,
                    child: const Text('Posting Ulasan',
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }
}