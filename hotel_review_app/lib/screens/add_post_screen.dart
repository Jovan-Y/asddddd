// lib/screens/add_post_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_review_app/models/post.dart';
import 'package:hotel_review_app/services/firestore_service.dart';
// import 'package:hotel_review_app/services/storage_service.dart'; // DIHAPUS
import 'package:hotel_review_app/services/location_service.dart';
import 'package:hotel_review_app/services/hotel_api_service.dart';
// import 'dart:io'; // DIHAPUS karena File tidak lagi digunakan
// import 'package:image_picker/image_picker.dart'; // DIHAPUS

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _hotelController = TextEditingController();
  // File? _imageFile; // DIHAPUS
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _selectedHotel;
  final HotelApiService _hotelApiService = HotelApiService();
  List<String> _hotelSuggestions = [];

  // final ImagePicker _picker = ImagePicker(); // DIHAPUS
  // final StorageService _storageService = StorageService(); // DIHAPUS
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi _pickImage() DIHAPUS

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi berhasil diambil!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat mengambil lokasi.')),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil lokasi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk memposting ulasan
  Future<void> _postReview() async {
    if (_statusController.text.isEmpty) { // Perubahan: Hanya cek status text
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // String? imageUrl; // DIHAPUS: Tidak ada lagi proses unggah gambar
    // if (_imageFile != null) { ... } // DIHAPUS

    final post = Post(
      id: '', // ID akan diisi oleh Firestore
      userId: _auth.currentUser?.uid ?? 'anonim',
      statusText: _statusController.text,
      imageUrl: null, // Selalu null karena tidak ada unggah gambar
      hotelName: _selectedHotel ?? _hotelController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      timestamp: DateTime.now(),
    );

    try {
      await _firestoreService.addPost(post);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil diposting!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Gagal memposting ulasan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memposting ulasan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mencari hotel dan menampilkan saran
  void _searchHotels(String query) async {
    if (query.isEmpty) {
      setState(() {
        _hotelSuggestions = [];
      });
      return;
    }
    List<String> suggestions = await _hotelApiService.searchHotels(query);
    setState(() {
      _hotelSuggestions = suggestions;
    });
  }

  @override
  void dispose() {
    _statusController.dispose();
    _hotelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Ulasan Baru'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _statusController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Bagikan pengalaman hotel Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bagian untuk pemilihan/tampilan gambar telah DIHAPUS
                  // _imageFile != null
                  //     ? Stack(...)
                  //     : Container(...)
                  TextField(
                    controller: _hotelController,
                    decoration: InputDecoration(
                      hintText: 'Nama Hotel (Opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.hotel),
                    ),
                    onChanged: _searchHotels, // Panggil pencarian saat teks berubah
                  ),
                  if (_hotelSuggestions.isNotEmpty)
                    SizedBox(
                      height: 200, // Batasi tinggi saran
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _hotelSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _hotelSuggestions[index];
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              setState(() {
                                _hotelController.text = suggestion;
                                _selectedHotel = suggestion; // Set hotel yang dipilih
                                _hotelSuggestions = []; // Sembunyikan saran
                              });
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.location_on),
                    label: Text(_latitude == null
                        ? 'Tambahkan Lokasi'
                        : 'Lokasi Ditambahkan (${_latitude!.toStringAsFixed(2)}, ${_longitude!.toStringAsFixed(2)})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _latitude == null ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _postReview,
                    child: const Text(
                      'Posting Ulasan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}