// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';

import '/flutter_flow/lat_lng.dart'
    as latlng; // Import do FlutterFlow para latlng.LatLng

class CustomMapWithRouteAndBins extends StatefulWidget {
  const CustomMapWithRouteAndBins({
    Key? key,
    required this.currentLocation,
    this.polylinePoints, // Agora é opcional (nullable)
    this.trashBinLocations, // Agora é opcional (nullable)
    required this.trashBinIconPath,
    this.width,
    this.height,
    this.initialZoom = 14.0,
  }) : super(key: key);

  final double? width;
  final double? height;
  final latlng.LatLng currentLocation;
  final List<dynamic>? polylinePoints; // nullable
  final List<dynamic>? trashBinLocations; // nullable
  final String trashBinIconPath;
  final double initialZoom;

  @override
  State<CustomMapWithRouteAndBins> createState() =>
      _CustomMapWithRouteAndBinsState();
}

class _CustomMapWithRouteAndBinsState extends State<CustomMapWithRouteAndBins> {
  late Completer<gmaps.GoogleMapController> _controller;
  gmaps.BitmapDescriptor? _trashBinIcon;

  @override
  void initState() {
    super.initState();
    _controller = Completer();
    _loadTrashBinIcon();
  }

  Future<void> _loadTrashBinIcon() async {
    final icon = await _getMarkerIcon(widget.trashBinIconPath, size: 48.0);
    setState(() {
      _trashBinIcon = icon;
    });
  }

  Future<gmaps.BitmapDescriptor> _getMarkerIcon(
    String imagePath, {
    double size = 48.0,
  }) async {
    final completer = Completer<gmaps.BitmapDescriptor>();

    // Sempre asset local
    final imageProvider = AssetImage(imagePath);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final config =
          createLocalImageConfiguration(context, size: Size(size, size));
      imageProvider
          .resolve(config)
          .addListener(ImageStreamListener((img, _) async {
        final byteData =
            await img.image.toByteData(format: ImageByteFormat.png);
        if (byteData != null) {
          final bitmap =
              gmaps.BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
          completer.complete(bitmap);
        } else {
          completer.complete(gmaps.BitmapDescriptor.defaultMarker);
        }
      }));
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (_trashBinIcon == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Converter currentLocation do FlutterFlow para gmaps.LatLng
    final currentPos = gmaps.LatLng(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
    );

    // Converter polylinePoints para gmaps.LatLng se não for nulo
    final routePoints = widget.polylinePoints != null
        ? widget.polylinePoints!.map((p) {
            final ffPoint = p as latlng.LatLng;
            return gmaps.LatLng(ffPoint.latitude, ffPoint.longitude);
          }).toList()
        : <gmaps.LatLng>[];

    // Converter trashBinLocations para gmaps.LatLng se não for nulo
    final binPositions = widget.trashBinLocations != null
        ? widget.trashBinLocations!.map((b) {
            final ffBin = b as latlng.LatLng;
            return gmaps.LatLng(ffBin.latitude, ffBin.longitude);
          }).toList()
        : <gmaps.LatLng>[];

    // Definir posição inicial (caso polyline tenha pontos, usar o primeiro ponto, caso contrário a posição atual)
    final initialPosition =
        routePoints.isNotEmpty ? routePoints.first : currentPos;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: gmaps.GoogleMap(
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: gmaps.CameraPosition(
          target: initialPosition,
          zoom: widget.initialZoom,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _buildMarkers(currentPos, binPositions),
        polylines: _buildPolylines(routePoints),
        mapType: gmaps.MapType.normal,
      ),
    );
  }

  Set<gmaps.Marker> _buildMarkers(
      gmaps.LatLng currentPos, List<gmaps.LatLng> bins) {
    final markers = <gmaps.Marker>{};

    // Marcador da localização atual
    markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('currentLocation'),
        position: currentPos,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueBlue),
      ),
    );

    // Marcadores de lixeiras se existirem
    for (final binPos in bins) {
      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId(binPos.toString()),
          position: binPos,
          icon: _trashBinIcon!,
        ),
      );
    }

    return markers;
  }

  Set<gmaps.Polyline> _buildPolylines(List<gmaps.LatLng> routePoints) {
    return {
      if (routePoints.isNotEmpty)
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId('route'),
          points: routePoints,
          color: Colors.blue,
          width: 4,
        ),
    };
  }
}
