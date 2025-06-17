// lib/screens/add_post_screen.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- Import untuk deteksi platform web
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hotel_review_app/models/post.dart';
import 'package:hotel_review_app/services/firestore_service.dart';
import 'package:hotel_review_app/services/location_service.dart';
import 'package:hotel_review_app/services/osm_api_service.dart';
import 'package:hotel_review_app/firebase_options.dart';
import 'package:image_picker/image_picker.dart';

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
  // Menggunakan XFile agar kompatibel di semua platform
  XFile? _imageFile;

  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final OsmApiService _osmApiService = OsmApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // ... (Fungsi ini tidak berubah)
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif.');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak.');
      }

      Position position = await Geolocator.getCurrentPosition();
      final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
          DefaultFirebaseOptions.currentPlatform.apiKey);

      if (mounted) {
        setState(() {
          _locationAddress = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ERROR Lokasi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // **PERBAIKAN:** Fungsi unggah gambar yang mendukung web dan mobile
  Future<String?> _uploadImage(XFile image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${user.uid}_${DateTime.now().toIso8601String()}.jpg');

      // Cek apakah aplikasi berjalan di web
      if (kIsWeb) {
        // Untuk web, unggah data gambar sebagai bytes
        await storageRef.putData(await image.readAsBytes());
      } else {
        // Untuk mobile, unggah file dari path
        await storageRef.putFile(File(image.path));
      }
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      // Menampilkan pesan error yang lebih spesifik kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: $e')),
      );
      return null;
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

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
      // Jika upload gagal, hentikan proses posting
      if (imageUrl == null) {
         setState(() => _isLoading = false);
         return;
      }
    }

    final post = Post(
      id: '',
      userId: user.uid,
      userName: user.displayName,
      statusText: _statusController.text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      rating: _rating,
      locationAddress: _locationAddress,
      hotelName: _selectedHotelName,
      hotelOsmId: _selectedPlaceId,
      likes: [],
    );

    try {
      await _firestoreService.addPost(post);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error posting review: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _searchHotels(String query) async {
    if (query.length < 3) {
      if (mounted) setState(() => _hotelSuggestions = []);
      return;
    }
    final results = await _osmApiService.searchHotels(query);
    if (mounted) setState(() => _hotelSuggestions = results);
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
                        setState(() {
                          _rating = rating;
                        });
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
                  if (_imageFile != null)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // **PERBAIKAN:** Menampilkan gambar sesuai platform
                        image: DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(_imageFile!.path)
                              : FileImage(File(_imageFile!.path)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(_imageFile == null ? 'Tambah Foto' : 'Ganti Foto'),
                  ),
                  const SizedBox(height: 16),
                  if (_locationAddress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(Icons.location_on, color: Colors.green, size: 16),
                           const SizedBox(width: 4),
                           Expanded(child: Text(_locationAddress!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
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
