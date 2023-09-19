import 'package:clippy_flutter/triangle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/info_window_provider.dart';

class CustomInfoWidget extends ConsumerWidget {
  const CustomInfoWidget({super.key, required this.providerObject});

  final InfoWindowController providerObject;

  @override
  Widget build(BuildContext context, ref) {

    final locationInfo = ref.watch(locationNameProvider(providerObject.vehicle?.position));

    return Visibility(
      visible: providerObject.showInfoWindow,
      child: (providerObject.vehicle == null || !providerObject.showInfoWindow)
          ? Container()
          : Container(
              margin: EdgeInsets.only(
                left: providerObject.leftMargin ?? 0,
                top: providerObject.topMargin ?? 0,
              ),
              // Custom InfoWindow Widget starts here
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.blueAccent.shade100,
                        ],
                        end: Alignment.bottomCenter,
                        begin: Alignment.topCenter,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    height: 125,
                    width: 290,
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                            "assets/marcedes.jpg",
                            height: 80,
                            width: 55,
                            fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              providerObject.vehicle!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Time: ",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Engine: ",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Speed: ",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Location: ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      providerObject.vehicle!.time,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      providerObject.vehicle!.status ? 'On' : 'Off',
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      providerObject.vehicle!.speed.toString(),
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    locationInfo.when(
                                        data: (data){
                                          return Text(
                                            data.toString(),
                                            maxLines: 2,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontSize: 13.2,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          );
                                        }, error: (e,s)=>const Text(
                                        'Not Available...',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 13.2,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        )),
                                        loading:()=> const Text(
                                      'Loading...',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 13.2,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      )))
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Triangle.isosceles(
                    edge: Edge.BOTTOM,
                    child: Container(
                      color: Colors.blueAccent.shade100,
                      width: 20.0,
                      height: 15.0,
                    ),
                  ),
                ],
              ),
              // Custom InfoWindow Widget ends here
            ),
    );
  }

}
