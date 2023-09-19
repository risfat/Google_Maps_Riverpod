import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Vehicle {
  final int id;
  final String name;
  final bool status;
  final String time;
  final double speed;
  final LatLng coordinate;
  final Position? position;

  Vehicle(
      this.id,
      this.name,
      this.status,
      this.time,
      this.speed,
      this.coordinate,
      this.position,
      );
}
