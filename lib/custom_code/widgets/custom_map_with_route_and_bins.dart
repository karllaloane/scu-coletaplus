// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
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
    this.polylinePoints,
    this.trashBins,
    required this.trashBinIconPath,
    this.width,
    this.height,
    this.initialZoom = 14.0,
    this.onInstructionUpdate,
    this.onNextCollectionDistanceUpdate,
  }) : super(key: key);

  final Function(String)? onInstructionUpdate;
  final Function(double)? onNextCollectionDistanceUpdate;
  final double? width;
  final double? height;
  final latlng.LatLng currentLocation; // Inicialização da posição
  final List<String>? polylinePoints;
  final List<LixeiraStruct>? trashBins;
  final String trashBinIconPath;
  final double initialZoom;

  @override
  State<CustomMapWithRouteAndBins> createState() =>
      _CustomMapWithRouteAndBinsState();
}

class _CustomMapWithRouteAndBinsState extends State<CustomMapWithRouteAndBins> {
  late Completer<gmaps.GoogleMapController> _controller;
  gmaps.BitmapDescriptor? _trashBinIcon;
  gmaps.LatLng? currentLocation;

  @override
  void initState() {
    super.initState();

    // Inicialize currentLocation com o valor fornecido pelo widget pai
    currentLocation = gmaps.LatLng(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
    );

    // Rastreie o movimento do dispositivo
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Atualiza a cada 10 metros
      ),
    ).listen((position) {
      if (mounted) {
        setState(() {
          currentLocation = gmaps.LatLng(position.latitude, position.longitude);
        });

        // Atualize as instruções de navegação
        _updateNavigationInstruction();
      }
    });

    _controller = Completer();
    _loadTrashBinIcon();
  }

  Future<void> _loadTrashBinIcon() async {
    try {
      // Carregar a imagem do asset
      final ByteData imageData = await rootBundle.load(widget.trashBinIconPath);

      // Redimensionar a imagem
      final codec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
        targetWidth: 100, // Largura desejada
        targetHeight: 150, // Altura desejada
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ByteData? byteData =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // Criar o BitmapDescriptor com a imagem redimensionada
        _trashBinIcon =
            gmaps.BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('[ERROR] Falha ao carregar o ícone da lixeira: $e');
    }
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) {
      print('[ERROR] Polyline está vazia.');
      return [];
    }

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
        if (points.isEmpty) {
          print('[WARNING] Polyline no índice $i está vazia.');
          continue;
        }
        polylines.add(
          gmaps.Polyline(
            polylineId: gmaps.PolylineId('route_$i'),
            points: points,
            color: Colors.green,
            width: 4,
          ),
        );
      }
    }
    return polylines;
  }

  void _updateNavigationInstruction() {
    if (widget.polylinePoints == null || widget.polylinePoints!.isEmpty) {
      print('[ERROR] Nenhuma polyline fornecida.');
      return;
    }

    // Decodifica os pontos da rota
    final routePoints = widget.polylinePoints!
        .map((encoded) => _decodePolyline(encoded))
        .expand((points) => points)
        .toList();

    if (routePoints.isEmpty) {
      print('[ERROR] Nenhum ponto decodificado da rota.');
      return;
    }

    // Localiza o ponto mais próximo na rota
    final currentIndex = routePoints.indexWhere((point) {
      final distance = _calculateDistance(currentLocation!, point);
      print(
          '[DEBUG] Distância para ponto ${point.latitude}, ${point.longitude}: $distance metros');
      return distance < 50; // Define a proximidade como 50 metros
    });

    if (currentIndex == -1) {
      print(
          '[DEBUG] Nenhum ponto próximo encontrado. Talvez o usuário esteja fora da rota.');
      widget.onInstructionUpdate?.call('Você está fora da rota.');
      return;
    }

    if (currentIndex == routePoints.length - 1) {
      print('[DEBUG] Último ponto alcançado. Destino atingido.');
      widget.onInstructionUpdate?.call('Você chegou ao destino!');
      return;
    }

    // Calcula o próximo ponto e a distância até ele
    final nextPoint = routePoints[currentIndex + 1];
    final distanceToNext = _calculateDistance(currentLocation!, nextPoint);
    print(
        '[DEBUG] Próximo ponto: ${nextPoint.latitude}, ${nextPoint.longitude}');
    print('[DEBUG] Distância para o próximo ponto: $distanceToNext metros');

    // Calcular direção (bearing) para o próximo ponto
    final bearing = _calculateBearing(currentLocation!, nextPoint);
    print('[DEBUG] Direção (bearing) para o próximo ponto: $bearing');

    // Gera a instrução de navegação
    String instruction;
    if (bearing > 30 && bearing < 150) {
      instruction =
          'Vire à direita em ${distanceToNext.toStringAsFixed(0)} metros.';
    } else if (bearing > -150 && bearing < -30) {
      instruction =
          'Vire à esquerda em ${distanceToNext.toStringAsFixed(0)} metros.';
    } else {
      instruction =
          'Siga em frente por ${distanceToNext.toStringAsFixed(0)} metros.';
    }

    print('[DEBUG] Instrução gerada: $instruction');
    widget.onInstructionUpdate?.call(instruction);

    // Adicional: Calcula a distância até a próxima coleta (lixeira)
    if (widget.trashBins != null && widget.trashBins!.isNotEmpty) {
      final distancesToBins = widget.trashBins!
          .where((bin) => bin.hasLatitude() && bin.hasLongitude())
          .map((bin) => _calculateDistance(
              currentLocation!, gmaps.LatLng(bin.latitude, bin.longitude)))
          .toList();

      // Encontra a menor distância
      if (distancesToBins.isNotEmpty) {
        final minDistance = distancesToBins.reduce((a, b) => a < b ? a : b);
        print('[DEBUG] Próxima lixeira está a $minDistance metros.');
        if (widget.onNextCollectionDistanceUpdate != null) {
          widget.onNextCollectionDistanceUpdate!(minDistance);
        }
      }
    }
  }

  double _calculateDistance(gmaps.LatLng point1, gmaps.LatLng point2) {
    const double earthRadius = 6371000;
    final lat1 = point1.latitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final deltaLat = (point2.latitude - point1.latitude) * pi / 180;
    final deltaLng = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _calculateBearing(gmaps.LatLng point1, gmaps.LatLng point2) {
    final lat1 = point1.latitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final deltaLng = (point2.longitude - point1.longitude) * pi / 180;

    final y = sin(deltaLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    if (_trashBinIcon == null || currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final initialPosition = currentLocation!;

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
        markers: _buildMarkers(currentLocation!, widget.trashBins),
        polylines: _buildPolylines(widget.polylinePoints),
        mapType: gmaps.MapType.normal,
      ),
    );
  }

  Set<gmaps.Marker> _buildMarkers(
      gmaps.LatLng currentPos, List<LixeiraStruct>? trashBins) {
    final markers = <gmaps.Marker>{};

    markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('currentLocation'),
        position: currentPos,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueBlue,
        ),
      ),
    );

    if (trashBins != null) {
      for (final bin in trashBins) {
        if (bin.hasLatitude() && bin.hasLongitude()) {
          markers.add(
            gmaps.Marker(
              markerId:
                  gmaps.MarkerId(bin.id ?? '${bin.latitude},${bin.longitude}'),
              position: gmaps.LatLng(bin.latitude, bin.longitude),
              icon: _trashBinIcon ?? gmaps.BitmapDescriptor.defaultMarker,
            ),
          );
        }
      }
    }

    return markers;
  }
}
