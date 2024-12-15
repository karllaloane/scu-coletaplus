import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';

String? getLatitude(LatLng? latlong) {
  if (latlong == null) {
    return null;
  }

  return '${latlong.latitude}';
}

String? getLongitude(LatLng? latlong) {
  if (latlong == null) {
    return null;
  }

  // Retorna a latitude e longitude como uma string formatada
  return '${latlong.longitude}';
}

List<LixeiraStruct> parseLixeira(String? jsonString) {
  // Decodificar o JSON recebido
  final decoded = jsonDecode(jsonString!);

  // Processar a lista de lixeiras
  final lixeiras = (decoded['lixeiras'] as List<dynamic>?)
      ?.map((lixeira) => LixeiraStruct(
            latitude: lixeira['latitude'] ?? 0.0,
            longitude: lixeira['longitude'] ?? 0.0,
            volumeAtual: lixeira['volumeAtual'],
            volumeMaximo: lixeira['volumeMaximo'],
            pesoAtual: lixeira['pesoAtual'],
            pesoMaximo: lixeira['pesoMaximo'],
            ultimaAtualizacao: lixeira['ultimaAtualizacao'] != null
                ? DateTime.parse(lixeira['ultimaAtualizacao'])
                : null,
            momentoUltimaColeta: lixeira['momentoUltimaColeta'] != null
                ? DateTime.parse(lixeira['momentoUltimaColeta'])
                : null,
            id: lixeira['id'],
          ))
      .toList();

  // Retornar a lista de lixeiras
  return lixeiras ?? [];
}

List<String>? parsePolylines(String? jsonString) {
  final decoded = jsonDecode(jsonString!);

  // Processar a lista de polylines
  final polylines = (decoded['polylines'] as List<String>?)
      ?.map((polyline) => polyline.toString())
      .toList();

  // Retornar a lista de polylines
  return polylines ?? [];
}
