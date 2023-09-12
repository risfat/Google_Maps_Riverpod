// ignore_for_file: prefer_final_fields, non_constant_identifier_names, unused_field, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_riverpod/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../services/map_services.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<LandingPage> {
//! Debounce for smooth ui upon searching
  Timer? _debounce;

//! Text editing controllers
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

//! boolean values for ui
  bool originNoResult = false;
  bool destinationNoResult = false;
  bool radiusSlider = false;
  bool pressedNear = false;

// !global keys
  final GlobalKey<FabCircularMenuPlusState> fabKey = GlobalKey();

//! variables & Constants

  ValueNotifier<String> _originAddress = ValueNotifier<String>('');
  ValueNotifier<String> _destinationAddress = ValueNotifier<String>('');
  String tokenKey = '';
  var tappedPoint;
  var radiusValue = 3000.0;
  List allFavoritePlaces = [];
  ValueNotifier<String> _searchAutoCompleteAddress = ValueNotifier<String>('');

//! completer for map
  Completer<GoogleMapController> _controller = Completer();

//! Initial camera position
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(23.7455317, 90.377631),
    zoom: 4,
  );

//! Getting uuid of the device of the user & session token
  var uuid = const Uuid();
  String _sessionToken = '122344';
  List<dynamic> _placesList = [];

//! Current camera position
  CameraPosition _currentCameraPosition =
      _kGooglePlex; //initially set to starting camera position.
//!onChange Function to assign session token to the user
  onChange(String inputValue) {
    if (_sessionToken.isEmpty) {
      _sessionToken = uuid.v4();
    }
    return getSuggestion(inputValue);
  }

//! Function to get current user location through GPS
  Future<Position> getCurrentUserLocation() async {
    await Geolocator.requestPermission().then((value) {
      FocusScope.of(context).requestFocus(FocusNode());
    }) //to close the keyboard if any
        .onError((error, stackTrace) => null);
    return await Geolocator.getCurrentPosition();
  }

//! function to retrieve the autocomplete data from get-places API of google maps
  getSuggestion(String input) async {
    String kPLACES_API_KEY = Constants
        .mapApiKey; //?Important!!!<<Place your API key Here,pass it as string>>
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    var body = response.body.toString();
    developer.log(body);
    if (response.statusCode == 200) {
      var placesData = await jsonDecode(body);
      return placesData;
    } else {
      throw Exception('Error loading autocomplete Data');
    }
  }

  int polylineIdCounter = 1;
  Set<Polyline> _polyLines = <Polyline>{};

  var tappedPlaceDetail;

  final key = Constants.mapApiKey; //!Important!!!<<Place your API key Here>>

//Circle
  Set<Circle> _circles = <Circle>{};

//! Function to set marker on the map upon searching
//Markers set
  Set<Marker> _markers = <Marker>{};
  Set<Marker> _markersDupe = <Marker>{};

//initial marker count value
  int markerIdCounter = 1;

  void _setMarker(LatLng point, {String? info}) {
    var counter = markerIdCounter++;

    final Marker marker = Marker(
        markerId: MarkerId('marker_$counter'),
        position: point,
        infoWindow: InfoWindow(title: info),
        onTap: () {},
        icon: BitmapDescriptor.defaultMarker);

    setState(() {
      _markers.add(marker);
    });
  }

//! Function to set polyline on the map upon searching
  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$polylineIdCounter';

    polylineIdCounter++;

    _polyLines.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 5,
        color: Colors.blue,
        points: points.map((e) => LatLng(e.latitude, e.longitude)).toList()));
  }

  void _setCircle(LatLng point) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 12)));
    setState(() {
      _circles.add(Circle(
          circleId: const CircleId('raj'),
          center: point,
          fillColor: Colors.blue.withOpacity(0.1),
          radius: radiusValue,
          strokeColor: Colors.blue,
          strokeWidth: 1));
      radiusSlider = true;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);

    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

//! initial State upon loading & dispose upon widget when completely removed from tree
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchAutoCompleteAddress.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _debounce?.cancel();
    PageController().dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Center(
              child: Column(
        children: [
          Stack(
            children: [
              //!stack of google map
              // ignore: sized_box_for_whitespace
              Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      _controller.complete(controller);
                    },
                    markers: _markers,
                    polylines: _polyLines,
                    circles: _circles,
                    onCameraMove: (CameraPosition position) {
                      _currentCameraPosition = position;
                    },
                    onTap: (point) {
                      tappedPoint = point;
                      _setCircle(point);
                    },
                  )),
              //!stack of navigate to user current location using GPS
              showGPSLocator(),
              //!Stack to show origin to Destination Direction
              getDirectionAndOriginToDestinationNavigate(),
              //!Stack to show navigation autocomplete result
              ValueListenableBuilder(
                valueListenable: _originAddress,
                builder: (context, value, _) {
                  return _originAddress.value.trim().isNotEmpty &&
                          _destinationAddress.value.trim().isEmpty
                      ? showOriginAutoCompleteListUponNavigation()
                      : Container();
                },
              ),
              ValueListenableBuilder(
                valueListenable: _destinationAddress,
                builder: (context, value, _) {
                  return _destinationAddress.value.trim().isNotEmpty
                      ? showDestinationAutoCompleteListUponNavigation()
                      : Container();
                },
              ),
            ],
          ),
        ],
      ))),
    );
  }

//! Function for GPS locator in stack
  Positioned showGPSLocator() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.12,
      right: 5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: () async {
            GoogleMapController controller = await _controller.future;
            developer.log('pressed');
            getCurrentUserLocation().then((value) async {
              await controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(value.latitude, value.longitude),
                      zoom: 14.2),
                ),
              );
              _setMarker(LatLng(value.latitude, value.longitude),
                  info: "My Current Location");
            });
          },
          child: const Icon(Icons.my_location_rounded),
        ),
      ),
    );
  }

//!function to get direction from origin to destination in stack
  Positioned getDirectionAndOriginToDestinationNavigate() {
    return Positioned(
      height: MediaQuery.of(context).size.height * 0.15,
      top: 55.0,
      left: 10.0,
      right: 10.0,
      child: Column(children: [
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width * 0.84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.blue.shade100,
          ),
          child: TextFormField(
            onTap: () {
              _destinationAddress.value = '';
            },
            onEditingComplete: () {
              FocusManager.instance.primaryFocus?.nextFocus();
              _originAddress.value = '';
            },
            autofocus: false,
            controller: _originController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              //!<<<<debounce
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _originAddress.value = val;
              });
              //!debounce>>>>
            },
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Origin',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(
          height: 3.0,
          width: MediaQuery.of(context).size.width * 0.84,
        ),
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width * 0.84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.blue.shade100,
          ),
          child: TextFormField(
            onTap: () {
              _originAddress.value = '';
            },
            controller: _destinationController,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.streetAddress,
            onChanged: (val) {
              //!<<<<debounce
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _destinationAddress.value = val;
              });
              //!debounce>>>>
            },
            onEditingComplete: () async {
              var directions = await MapServices().getDirections(
                  _originController.text, _destinationController.text);
              _markers = {};
              _polyLines = {};
              gotoPlace(
                  directions['start_location']['lat'],
                  directions['start_location']['lng'],
                  directions['end_location']['lat'],
                  directions['end_location']['lng'],
                  directions['bounds_ne'],
                  directions['bounds_sw']);
              _setPolyline(directions['polyline_decoded']);
              FocusManager.instance.primaryFocus
                  ?.unfocus(); //to hide keyboard upon pressing done
              _originAddress.value = '';
              _destinationAddress.value = '';
            },
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
                border: InputBorder.none,
                hintText: 'Destination',
                suffixIcon: Container(
                    child: IconButton(
                        onPressed: () async {
                          var directions = await MapServices()
                              .getDirections(_originController.text,
                                  _destinationController.text);
                          _markers = {};
                          _polyLines = {};
                          gotoPlace(
                              directions['start_location']['lat'],
                              directions['start_location']['lng'],
                              directions['end_location']['lat'],
                              directions['end_location']['lng'],
                              directions['bounds_ne'],
                              directions['bounds_sw']);
                          _setPolyline(directions['polyline_decoded']);
                          FocusManager.instance.primaryFocus
                              ?.unfocus(); //to hide keyboard upon pressing done
                          _originAddress.value = '';
                          _destinationAddress.value = '';
                          setState(() {});
                        },
                        icon: const Icon(Icons.search)))),
          ),
        )
      ]),
    );
  }

//!Function to show auto complete suggestion in stack upon origin to destination navigation in flutter
  Positioned showOriginAutoCompleteListUponNavigation() {
    return originNoResult == false && _originAddress.value.trim().length >= 2
        ? Positioned(
            top: 180,
            right: 20,
            left: 20,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.blue.shade100.withOpacity(0.7),
              ),
              child: FutureBuilder(
                future: onChange(_originAddress.value),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data['predictions'].length ?? 3,
                          padding: const EdgeInsets.only(top: 0, right: 0),
                          itemBuilder: (BuildContext context, int index) {
                            if (snapshot.hasData) {
                              return ListTile(
                                title: Text(
                                  snapshot.data['predictions'][index]
                                          ['description']
                                      .toString(),
                                  style: const TextStyle(
                                      fontFamily: 'WorkSans',
                                      fontWeight: FontWeight.w500),
                                ),
                                onTap: () {
                                  setState(() {
                                    _originController.text = snapshot
                                        .data['predictions'][index]
                                            ['description']
                                        .toString();

                                    _originAddress.value = '';
                                  });
                                  FocusManager.instance.primaryFocus
                                      ?.nextFocus();
                                  _originAddress.value = '';
                                },
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              setState(() {
                                if (_originAddress.value.trim().length >= 2 &&
                                    snapshot.hasData) {
                                  originNoResult = true;
                                }
                              });
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        )
                      : const Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Loading...",
                                textScaleFactor: 1.5,
                              ),
                            ),
                          ],
                        ));
                },
              ),
            ),
          )
        : Positioned(
            top: 180,
            right: 20,
            left: 20,
            child: Container(
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.blue.shade100.withOpacity(0.7),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Column(children: [
                    GestureDetector(
                      onTap: () async {
                        developer.log('pressed');
                        await getCurrentUserLocation().then((value) {
                          placemarkFromCoordinates(
                                  value.latitude, value.longitude)
                              .then((placeMark) {
                            _originController.text =
                                '${placeMark.reversed.last.name} ${placeMark.reversed.last.subLocality} ${placeMark.reversed.last.locality} ${placeMark.reversed.last.administrativeArea} ${placeMark.reversed.last.country}';
                            _originController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: _originController.text.length));
                            FocusManager.instance.primaryFocus?.nextFocus();
                            _originAddress.value = '';
                          });
                        }).then((value) =>
                            FocusManager.instance.primaryFocus?.nextFocus());
                      },
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(
                            top: 10, right: 15, left: 15, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.white60.withOpacity(1),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.my_location_rounded,
                              color: Colors.black45,
                              size: 30,
                            ),
                            Text(" Use Your Location",
                                textScaleFactor: 1.1,
                                style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const Text('No results to show',
                        style: TextStyle(
                            fontFamily: 'WorkSans', fontWeight: FontWeight.w400)),
                    const SizedBox(height: 5.0),
                    SizedBox(
                      width: 125.0,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _originController.clear();
                            _destinationController.clear();
                          });
                        },
                        child: const Center(
                          child: Text(
                            'Close',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'WorkSans',
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              ),
            ));
  }

  Positioned showDestinationAutoCompleteListUponNavigation() {
    return destinationNoResult == false &&
            _destinationAddress.value.trim().length >= 2
        ? Positioned(
            top: 180,
            right: 20,
            left: 20,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.blue.shade100.withOpacity(0.7),
              ),
              child: FutureBuilder(
                future: onChange(_destinationAddress.value),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data['predictions'].length ?? 3,
                          padding: const EdgeInsets.only(top: 0, right: 0),
                          itemBuilder: (BuildContext context, int index) {
                            if (snapshot.hasData) {
                              return ListTile(
                                title: Text(
                                  snapshot.data['predictions'][index]
                                          ['description']
                                      .toString(),
                                  style: const TextStyle(
                                      fontFamily: 'WorkSans',
                                      fontWeight: FontWeight.w500),
                                ),
                                onTap: () async {
                                  _destinationController.text = snapshot
                                      .data['predictions'][index]['description']
                                      .toString();
                                  var directions = await MapServices()
                                      .getDirections(_originController.text,
                                          _destinationController.text);
                                  _markers = {};
                                  _polyLines = {};
                                  gotoPlace(
                                      directions['start_location']['lat'],
                                      directions['start_location']['lng'],
                                      directions['end_location']['lat'],
                                      directions['end_location']['lng'],
                                      directions['bounds_ne'],
                                      directions['bounds_sw']);
                                  _setPolyline(directions['polyline_decoded']);
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  _originAddress.value = '';
                                  _destinationAddress.value = '';

                                  setState(() {});
                                },
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              setState(() {
                                if (_destinationAddress.value.trim().length >=
                                        2 &&
                                    snapshot.hasData) {
                                  destinationNoResult = true;
                                }
                              });
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        )
                      : const Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Loading...",
                                textScaleFactor: 1.5,
                              ),
                            ),
                          ],
                        ));
                },
              ),
            ),
          )
        : Positioned(
            top: 180,
            right: 20,
            left: 20,
            child: Container(
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.red.shade100.withOpacity(0.7),
              ),
              child: Center(
                child: Column(children: [
                  const Text('No results to show',
                      style: TextStyle(
                          fontFamily: 'WorkSans', fontWeight: FontWeight.w400)),
                  const SizedBox(height: 5.0),
                  Container(
                    width: 125.0,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _originController.clear();
                          _destinationController.clear();
                        });
                      },
                      child: const Center(
                        child: Text(
                          'Close',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'WorkSans',
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            ));
  }

//! function for navigation to a specific lat-lang
  searchAndNavigate(GoogleMapController mapController, String inputValue,
      {int? zoom}) async {
    await locationFromAddress(inputValue).then(
      (result) => {
        developer.log(result.toString()),
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(result.last.latitude, result.last.longitude),
                zoom: zoom!.toDouble() < 13 ? 13 : zoom.toDouble()),
          ),
        ),
        _setMarker(LatLng(result.last.latitude, result.last.longitude),
            info: inputValue),
      },
    );
  }

//! function to go to a place with close precision and with end lat and lang
  gotoPlace(double lat, double lng, double endLat, double endLng,
      Map<String, dynamic> boundsNe, Map<String, dynamic> boundsSw) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
    _setMarker(LatLng(lat, lng));
    _setMarker(LatLng(endLat, endLng));
  }
}