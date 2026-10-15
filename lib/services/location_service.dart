import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Controlla se il GPS è attivo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('I servizi di localizzazione sono disabilitati.');
    }

    // 2. Controlla i permessi dell'app
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permessi di localizzazione negati.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permessi negati permanentemente. Cambiali nelle impostazioni.');
    }

    // 3. Ottieni la posizione
    return await Geolocator.getCurrentPosition();
  }
}