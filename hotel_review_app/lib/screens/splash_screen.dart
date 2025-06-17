// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hotel_review_app/main.dart'; // Import main.dart untuk mengakses AuthHandler

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    // Setelah 3 detik, navigasi ke AuthHandler
    // AuthHandler yang akan memutuskan apakah akan menampilkan HomeScreen atau AuthGate
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthHandler()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 188, 156), // Warna dari contoh Anda
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          // Placeholder logo. Ganti dengan logo Anda sendiri.
          child: Image.asset('assets/gojo.jpg', width: 150, height: 150)
        ),
      ),
    );
  }
}