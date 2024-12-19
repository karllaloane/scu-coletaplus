// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LixeiraStruct extends BaseStruct {
  LixeiraStruct({
    double? latitude,
    double? longitude,
    double? volumeAtual,
    double? volumeMaximo,
    double? pesoMaximo,
    double? pesoAtual,
    DateTime? ultimaAtualizacao,
    DateTime? momentoUltimaColeta,
    String? id,
    String? descricao,
    bool? isVisitada,
  })  : _latitude = latitude,
        _longitude = longitude,
        _volumeAtual = volumeAtual,
        _volumeMaximo = volumeMaximo,
        _pesoMaximo = pesoMaximo,
        _pesoAtual = pesoAtual,
        _ultimaAtualizacao = ultimaAtualizacao,
        _momentoUltimaColeta = momentoUltimaColeta,
        _id = id,
        _descricao = descricao,
        _isVisitada = isVisitada;

  // "latitude" field.
  double? _latitude;
  double get latitude => _latitude ?? 0.0;
  set latitude(double? val) => _latitude = val;

  void incrementLatitude(double amount) => latitude = latitude + amount;

  bool hasLatitude() => _latitude != null;

  // "longitude" field.
  double? _longitude;
  double get longitude => _longitude ?? 0.0;
  set longitude(double? val) => _longitude = val;

  void incrementLongitude(double amount) => longitude = longitude + amount;

  bool hasLongitude() => _longitude != null;

  // "volumeAtual" field.
  double? _volumeAtual;
  double get volumeAtual => _volumeAtual ?? 0.0;
  set volumeAtual(double? val) => _volumeAtual = val;

  void incrementVolumeAtual(double amount) =>
      volumeAtual = volumeAtual + amount;

  bool hasVolumeAtual() => _volumeAtual != null;

  // "volumeMaximo" field.
  double? _volumeMaximo;
  double get volumeMaximo => _volumeMaximo ?? 0.0;
  set volumeMaximo(double? val) => _volumeMaximo = val;

  void incrementVolumeMaximo(double amount) =>
      volumeMaximo = volumeMaximo + amount;

  bool hasVolumeMaximo() => _volumeMaximo != null;

  // "pesoMaximo" field.
  double? _pesoMaximo;
  double get pesoMaximo => _pesoMaximo ?? 0.0;
  set pesoMaximo(double? val) => _pesoMaximo = val;

  void incrementPesoMaximo(double amount) => pesoMaximo = pesoMaximo + amount;

  bool hasPesoMaximo() => _pesoMaximo != null;

  // "pesoAtual" field.
  double? _pesoAtual;
  double get pesoAtual => _pesoAtual ?? 0.0;
  set pesoAtual(double? val) => _pesoAtual = val;

  void incrementPesoAtual(double amount) => pesoAtual = pesoAtual + amount;

  bool hasPesoAtual() => _pesoAtual != null;

  // "ultimaAtualizacao" field.
  DateTime? _ultimaAtualizacao;
  DateTime? get ultimaAtualizacao => _ultimaAtualizacao;
  set ultimaAtualizacao(DateTime? val) => _ultimaAtualizacao = val;

  bool hasUltimaAtualizacao() => _ultimaAtualizacao != null;

  // "momentoUltimaColeta" field.
  DateTime? _momentoUltimaColeta;
  DateTime? get momentoUltimaColeta => _momentoUltimaColeta;
  set momentoUltimaColeta(DateTime? val) => _momentoUltimaColeta = val;

  bool hasMomentoUltimaColeta() => _momentoUltimaColeta != null;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "descricao" field.
  String? _descricao;
  String get descricao => _descricao ?? '';
  set descricao(String? val) => _descricao = val;

  bool hasDescricao() => _descricao != null;

  // "isVisitada" field.
  bool? _isVisitada = false;
  bool get isVisitada => _isVisitada ?? false;
  set isVisitada(bool? val) => _isVisitada = val;

  bool hasIsVisitada() => _isVisitada != null;

  static LixeiraStruct fromMap(Map<String, dynamic> data) => LixeiraStruct(
        latitude: castToType<double>(data['latitude']),
        longitude: castToType<double>(data['longitude']),
        volumeAtual: castToType<double>(data['volumeAtual']),
        volumeMaximo: castToType<double>(data['volumeMaximo']),
        pesoMaximo: castToType<double>(data['pesoMaximo']),
        pesoAtual: castToType<double>(data['pesoAtual']),
        //ultimaAtualizacao: data['ultimaAtualizacao'] as DateTime?,
        //momentoUltimaColeta: data['momentoUltimaColeta'] as DateTime?,
    ultimaAtualizacao: data['ultimaAtualizacao'] != null
        ? DateTime.tryParse(data['ultimaAtualizacao'])
        : null,
    momentoUltimaColeta: data['momentoUltimaColeta'] != null
        ? DateTime.tryParse(data['momentoUltimaColeta'])
        : null,
        id: data['id'] as String?,
        descricao: data['descricao'] as String?,
      );

  static LixeiraStruct? maybeFromMap(dynamic data) =>
      data is Map ? LixeiraStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'latitude': _latitude,
        'longitude': _longitude,
        'volumeAtual': _volumeAtual,
        'volumeMaximo': _volumeMaximo,
        'pesoMaximo': _pesoMaximo,
        'pesoAtual': _pesoAtual,
        'ultimaAtualizacao': _ultimaAtualizacao?.toIso8601String(),
        'momentoUltimaColeta': _momentoUltimaColeta?.toIso8601String(),
        'id': _id,
        'descricao': _descricao,
        'isVisitada': _isVisitada,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'latitude': serializeParam(
          _latitude,
          ParamType.double,
        ),
        'longitude': serializeParam(
          _longitude,
          ParamType.double,
        ),
        'volumeAtual': serializeParam(
          _volumeAtual,
          ParamType.double,
        ),
        'volumeMaximo': serializeParam(
          _volumeMaximo,
          ParamType.double,
        ),
        'pesoMaximo': serializeParam(
          _pesoMaximo,
          ParamType.double,
        ),
        'pesoAtual': serializeParam(
          _pesoAtual,
          ParamType.double,
        ),
        'ultimaAtualizacao': serializeParam(
          _ultimaAtualizacao,
          ParamType.DateTime,
        ),
        'momentoUltimaColeta': serializeParam(
          _momentoUltimaColeta,
          ParamType.DateTime,
        ),
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'descricao': serializeParam(
          _descricao,
          ParamType.String,
        ),
        'isVisitada': serializeParam(
          _isVisitada,
          ParamType.bool,
        ),
      }.withoutNulls;

  static LixeiraStruct fromSerializableMap(Map<String, dynamic> data) =>
      LixeiraStruct(
        latitude: deserializeParam(
          data['latitude'],
          ParamType.double,
          false,
        ),
        longitude: deserializeParam(
          data['longitude'],
          ParamType.double,
          false,
        ),
        volumeAtual: deserializeParam(
          data['volumeAtual'],
          ParamType.double,
          false,
        ),
        volumeMaximo: deserializeParam(
          data['volumeMaximo'],
          ParamType.double,
          false,
        ),
        pesoMaximo: deserializeParam(
          data['pesoMaximo'],
          ParamType.double,
          false,
        ),
        pesoAtual: deserializeParam(
          data['pesoAtual'],
          ParamType.double,
          false,
        ),
        ultimaAtualizacao: deserializeParam(
          data['ultimaAtualizacao'],
          ParamType.DateTime,
          false,
        ),
        momentoUltimaColeta: deserializeParam(
          data['momentoUltimaColeta'],
          ParamType.DateTime,
          false,
        ),
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        descricao: deserializeParam(
          data['descricao'],
          ParamType.String,
          false,
        ),
        isVisitada: deserializeParam(
          data['isVisitada'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'LixeiraStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LixeiraStruct &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        volumeAtual == other.volumeAtual &&
        volumeMaximo == other.volumeMaximo &&
        pesoMaximo == other.pesoMaximo &&
        pesoAtual == other.pesoAtual &&
        ultimaAtualizacao == other.ultimaAtualizacao &&
        momentoUltimaColeta == other.momentoUltimaColeta &&
        id == other.id &&
        descricao == other.descricao &&
        isVisitada == other.isVisitada;
  }

  @override
  int get hashCode => const ListEquality().hash([
        latitude,
        longitude,
        volumeAtual,
        volumeMaximo,
        pesoMaximo,
        pesoAtual,
        ultimaAtualizacao,
        momentoUltimaColeta,
        id,
        descricao,
        isVisitada
      ]);
}

LixeiraStruct createLixeiraStruct({
  double? latitude,
  double? longitude,
  double? volumeAtual,
  double? volumeMaximo,
  double? pesoMaximo,
  double? pesoAtual,
  DateTime? ultimaAtualizacao,
  DateTime? momentoUltimaColeta,
  String? id,
  String? descricao,
  bool? isVisitada,
}) =>
    LixeiraStruct(
      latitude: latitude,
      longitude: longitude,
      volumeAtual: volumeAtual,
      volumeMaximo: volumeMaximo,
      pesoMaximo: pesoMaximo,
      pesoAtual: pesoAtual,
      ultimaAtualizacao: ultimaAtualizacao,
      momentoUltimaColeta: momentoUltimaColeta,
      id: id,
      descricao: descricao,
      isVisitada: false,
    );
