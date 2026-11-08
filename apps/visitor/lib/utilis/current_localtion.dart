import 'package:geolocator/geolocator.dart';

Future<Position> getUserCurrentPosition() async {
  Position position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
  );
  return position;
}
