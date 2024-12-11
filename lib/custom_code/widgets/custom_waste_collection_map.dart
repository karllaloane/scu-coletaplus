// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'dart:async';

class CustomWasteCollectionMap extends StatefulWidget {
  const CustomWasteCollectionMap({
    Key? key,
    this.width,
    this.height,
    required this.currentLocation, // Recebendo a localização como parâmetro
    required this.polylinePoints,
    required this.trashBinLocations,
    this.initialZoom = 14.0,
    this.mapType = gmaps.MapType.normal,
    this.trashBinIconPath = 'assets/images/trash_bin_icon.png',
  }) : super(key: key);

  final double? width;
  final double? height;

  /// Localização atual do usuário (FFLatLng do FlutterFlow)
  final LatLng currentLocation;

  /// Lista de pontos (FFLatLng) para a rota
  final List<dynamic> polylinePoints;

  /// Lista de posições das lixeiras (FFLatLng)
  final List<dynamic> trashBinLocations;

  /// Zoom inicial
  final double initialZoom;

  /// Tipo do mapa (normal, satellite, terrain, hybrid)
  final gmaps.MapType mapType;

  /// Caminho do ícone da lixeira
  final String trashBinIconPath;

  @override
  State<CustomWasteCollectionMap> createState() =>
      _CustomWasteCollectionMapState();
}

class _CustomWasteCollectionMapState extends State<CustomWasteCollectionMap> {
  late gmaps.GoogleMapController _controller;
  gmaps.BitmapDescriptor? _trashBinIcon;

  @override
  void initState() {
    super.initState();
    _setCustomMarker();
  }

  Future<void> _setCustomMarker() async {
    // Carrega o ícone customizado da lixeira
    final icon = await gmaps.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      widget.trashBinIconPath,
    );
    setState(() {
      _trashBinIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Caso ainda não tenha carregado o ícone
    if (_trashBinIcon == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Converter a lista da polyline de FFLatLng para gmaps.LatLng
    final routePoints = widget.polylinePoints.map((p) {
      final ffPoint = p as LatLng; // FFLatLng
      return gmaps.LatLng(ffPoint.latitude, ffPoint.longitude);
    }).toList();

    // Converter localização atual (FFLatLng) para gmaps.LatLng
    final currentPos = gmaps.LatLng(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
    );

    // Caso a polyline não tenha pontos, usamos a posição atual como referência
    final initialPosition =
        routePoints.isNotEmpty ? routePoints.first : currentPos;

    // Converter a lista de lixeiras de FFLatLng para gmaps.LatLng
    final bins = widget.trashBinLocations.map((b) {
      final ffBin = b as LatLng; // FFLatLng
      return gmaps.LatLng(ffBin.latitude, ffBin.longitude);
    }).toList();

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(
          target: initialPosition,
          zoom: widget.initialZoom,
        ),
        onMapCreated: (gmaps.GoogleMapController controller) {
          _controller = controller;
        },
        markers: _buildMarkers(currentPos, bins),
        polylines: _buildPolylines(routePoints),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
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

    // Marcadores de lixeiras
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
