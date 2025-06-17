// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_review_app/screens/home_screen.dart'; // Import HomeScreen

// Anda bisa menghapus bagian ini jika menggunakan flutterfire configure
// import 'firebase_options.dart'; // Import file firebase_options.dart jika menggunakan

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Pastikan Anda telah menambahkan konfigurasi Firebase ke file main.dart atau
    // mengandalkan firebase_options.dart yang dihasilkan secara otomatis oleh FlutterFire CLI.
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // Gunakan ini jika Anda memiliki firebase_options.dart
    );
    print("Firebase berhasil diinisialisasi.");
  } catch (e) {
    print("Gagal menginisialisasi Firebase: $e");
    // Anda bisa menampilkan pesan error di UI jika ingin
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isFirebaseInitialized = false; // Status inisialisasi Firebase
  String? _authError; // Untuk menyimpan pesan kesalahan autentikasi

  @override
  void initState() {
    super.initState();
    // Memeriksa status inisialisasi Firebase
    if (Firebase.apps.isNotEmpty) {
      _isFirebaseInitialized = true;
    }

    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
        _authError = null; // Reset error saat status berubah
      });
      if (user == null && _isFirebaseInitialized) {
        // Jika tidak ada user yang login dan Firebase sudah diinisialisasi, coba login anonim
        _signInAnonymously();
      }
    });

    // Handle kasus jika _auth.authStateChanges() tidak langsung memicu sign-in
    if (_auth.currentUser == null && _isFirebaseInitialized) {
      _signInAnonymously();
    }
  }

  // Fungsi untuk login anonim
  Future<void> _signInAnonymously() async {
    if (_auth.currentUser != null) return; // Jangan sign-in lagi jika sudah ada user
    setState(() {
      _authError = null; // Bersihkan error sebelumnya
    });
    try {
      await _auth.signInAnonymously();
      print("Pengguna berhasil login secara anonim");
    } catch (e) {
      print("Gagal login anonim: $e");
      setState(() {
        _authError = "Gagal login. Periksa koneksi atau konfigurasi Firebase: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan widget home berdasarkan status user dan error
    Widget homeWidget;
    if (!_isFirebaseInitialized) {
      homeWidget = const Scaffold(
        backgroundColor: Colors.grey, // Latar belakang abu-abu agar indikator terlihat
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menginisialisasi Firebase...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    } else if (_user == null) {
      homeWidget = Scaffold(
        backgroundColor: Colors.blueGrey, // Latar belakang abu-abu kebiruan
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              const SizedBox(height: 16),
              const Text(
                'Mencoba login anonim...',
                style: TextStyle(color: Colors.white),
              ),
              if (_authError != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    _authError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      homeWidget = const HomeScreen();
    }

    return MaterialApp(
      title: 'Aplikasi Ulasan Hotel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            shadowColor: Colors.blue.withOpacity(0.5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: homeWidget,
    );
  }
}