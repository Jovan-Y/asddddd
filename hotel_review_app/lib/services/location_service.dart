// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Mendapatkan posisi saat ini
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Tes apakah layanan lokasi diaktifkan.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Layanan lokasi tidak diaktifkan, jangan lanjutkan
      // meminta izin atau mengakses lokasi.
      return Future.error('Layanan lokasi dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin ditolak, jangan lanjutkan
        // mengakses lokasi.
        return Future.error('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak secara permanen, kita tidak dapat meminta izin.
      return Future.error(
          'Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.');
    }

    // Ketika kita mencapai di sini, izin telah diberikan dan kita dapat
    // melanjutkan mengakses posisi perangkat.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}