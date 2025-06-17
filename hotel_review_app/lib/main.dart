// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_review_app/screens/auth_gate.dart';
import 'package:hotel_review_app/screens/home_screen.dart';
import 'package:hotel_review_app/screens/splash_screen.dart'; // <-- IMPORT BARU
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Ulasan Hotel',
      theme: ThemeData(
        // ... tema Anda tidak berubah
      ),
      // --- PERUBAHAN DI SINI ---
      // Atur SplashScreen sebagai halaman utama
      home: const SplashScreen(),
    );
  }
}

// Widget AuthHandler tidak perlu diubah
class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const AuthGate();
      },
    );
  }
}