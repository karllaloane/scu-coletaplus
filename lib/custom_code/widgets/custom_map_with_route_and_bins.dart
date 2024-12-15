// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
    this.trashBins, // Agora é opcional (nullable)
    required this.trashBinIconPath,
    this.width,
    this.height,
    this.initialZoom = 14.0,
  }) : super(key: key);

  final double? width;
  final double? height;
  final latlng.LatLng currentLocation;
  final List<String>? polylinePoints; // nullable
  final List<Lixeira>? trashBins; // nullable
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
    final icon = await _getMarkerIcon(widget.trashBinIconPath, size: 100.0);
    setState(() {
      _trashBinIcon = icon;
    });
  }

  Future<gmaps.BitmapDescriptor> _getMarkerIcon(
    String imagePath, {
    double size = 150.0,
  }) async {
    final imageData = await rootBundle.load(imagePath);
    final codec = await instantiateImageCodec(
      imageData.buffer.asUint8List(),
      targetWidth: size.toInt(),
      targetHeight: size.toInt(),
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      return gmaps.BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    }
    return gmaps.BitmapDescriptor.defaultMarker;
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    final polylinePoints = PolylinePoints().decodePolyline(encoded);
    return polylinePoints
        .map((point) => gmaps.LatLng(point.latitude, point.longitude))
        .toList();
  }

  Set<gmaps.Polyline> _buildPolylines(List<String>? encodedPolylines) {
    final polylines = <gmaps.Polyline>{};
    if (encodedPolylines != null) {
      for (int i = 0; i < encodedPolylines.length; i++) {
        final points = _decodePolyline(encodedPolylines[i]);
        polylines.add(
          gmaps.Polyline(
            polylineId: gmaps.PolylineId('route_$i'),
            points: points,
            color: Colors.blue,
            width: 4,
          ),
        );
      }
    }
    return polylines;
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

    // Converter trashBinLocations para gmaps.LatLng se não for nulo
    final binPositions = widget.trashBins != null
        ? widget.trashBins!
            .where((b) =>
                b.latitude != null &&
                b.longitude != null) // Verifica se os valores não são nulos
            .map((b) => gmaps.LatLng(
                b.latitude!, b.longitude!)) // Confirma que não são nulos
            .toList()
        : <gmaps.LatLng>[];

    // Definir posição inicial
    final initialPosition = currentPos;

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
        polylines: _buildPolylines(widget.polylinePoints),
        mapType: gmaps.MapType.normal,
      ),
    );
  }

  Set<gmaps.Marker> _buildMarkers(
      gmaps.LatLng currentPos, List<Lixeira>? trashBins) {
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

    // Marcadores das lixeiras
    if (trashBins != null) {
      for (final bin in trashBins) {
        markers.add(
          gmaps.Marker(
            markerId:
                gmaps.MarkerId(bin.id ?? '${bin.latitude},${bin.longitude}'),
            position: gmaps.LatLng(bin.latitude, bin.longitude),
            icon: _trashBinIcon ?? gmaps.BitmapDescriptor.defaultMarker,
            infoWindow: gmaps.InfoWindow(
              title: 'Lixeira',
              snippet:
                  'Volume Atual: ${bin.volumeAtual ?? 'N/A'} / ${bin.volumeMaximo ?? 'N/A'}\nPeso Atual: ${bin.pesoAtual ?? 'N/A'} / ${bin.pesoMaximo ?? 'N/A'}',
            ),
          ),
        );
      }
    }

    return markers;
  }
}
