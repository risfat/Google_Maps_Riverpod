import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/vehicle_model.dart';
import '../services/map_services.dart';

final infoWindowProvider = ChangeNotifierProvider<InfoWindowController>((ref) {
  return InfoWindowController();
});

class InfoWindowController extends ChangeNotifier {
  bool _showInfoWindow = false;
  bool _tempHidden = false;
  Vehicle? _vehicle;
  double? _leftMargin;
  double? _topMargin;

  void rebuildInfoWindow() {
    notifyListeners();
  }

  void updateVehicle(Vehicle vehicle) {
    _vehicle = vehicle;
  }

  void updateVisibility(bool visibility) {
    _showInfoWindow = visibility;
  }

  void updateInfoWindow(
      BuildContext context,
      GoogleMapController controller,
      LatLng location,
      double infoWindowWidth,
      double markerOffset,
      ) async {
    ScreenCoordinate screenCoordinate =
    await controller.getScreenCoordinate(location);
    double devicePixelRatio =
    Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
    double left = (screenCoordinate.x.toDouble() / devicePixelRatio) -
        (infoWindowWidth / 2);
    double top =
        (screenCoordinate.y.toDouble() / devicePixelRatio) - markerOffset;
    if (left < 0 || top < 0) {
      _tempHidden = true;
    } else {
      _tempHidden = false;
      _leftMargin = left;
      _topMargin = top;
    }
  }

  bool get showInfoWindow =>
      (_showInfoWindow == true && _tempHidden == false) ? true : false;

  double? get leftMargin => _leftMargin;

  double? get topMargin => _topMargin;

  Vehicle? get vehicle => _vehicle;
}


final locationNameProvider =
FutureProvider.family<String?, Position?>((ref, position) async {
  return ref.watch(mapServiceProvider).getAddressFromLatLng(position);
});
