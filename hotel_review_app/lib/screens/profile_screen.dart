// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hotel_review_app/main.dart';
import 'package:hotel_review_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final User? user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey[200],
      body: user == null
          ? const Center(child: Text('Tidak ada pengguna yang login.'))
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Profile Header
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'Pengguna Baru',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email ?? 'Tidak ada email',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(),
                // Profile Menu
                ProfileMenuItem(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: user.email ?? '-',
                ),
                ProfileMenuItem(
                  icon: Icons.person_pin,
                  title: 'User ID',
                  subtitle: user.uid,
                  isSubtitleSelectable: true,
                ),
                ProfileMenuItem(
                  icon: Icons.verified_user,
                  title: 'Status Verifikasi Email',
                  subtitle: user.emailVerified ? 'Terverifikasi' : 'Belum Terverifikasi',
                ),
                const Divider(),
                const SizedBox(height: 16),
                // **PERBAIKAN FITUR LOGOUT**
                ElevatedButton.icon(
                  onPressed: () async {
                    // Tampilkan dialog konfirmasi sebelum logout
                    final bool? shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text('Apakah Anda yakin ingin keluar?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Ya, Keluar'),
                            ),
                          ],
                        );
                      },
                    );

                    // Jika pengguna mengkonfirmasi, lakukan logout
                    if (shouldLogout == true) {
                      await authService.signOut();
                      // Navigasi ke AuthHandler dan hapus semua rute sebelumnya
                      // Ini akan memastikan pengguna kembali ke halaman login (AuthGate)
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const AuthHandler()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('LOGOUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
    );
  }
}

// Widget kustom untuk item menu di profil
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSubtitleSelectable;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSubtitleSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: isSubtitleSelectable
          ? SelectableText(subtitle, style: TextStyle(color: Colors.grey[700]))
          : Text(subtitle, style: TextStyle(color: Colors.grey[700])),
    );
  }
}
