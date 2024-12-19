// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import '/flutter_flow/flutter_flow_util.dart';

class VeiculoStruct extends FFFirebaseStruct {
  VeiculoStruct({
    int? capacidade,
    String? placa,
    EstadoVeiculo? estado,
    int? id,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _capacidade = capacidade,
        _placa = placa,
        _estado = estado,
        _id = id,
        super(firestoreUtilData);

  // "capacidade" field.
  int? _capacidade;
  int get capacidade => _capacidade ?? 10;
  set capacidade(int? val) => _capacidade = val;

  void incrementCapacidade(int amount) => capacidade = capacidade + amount;

  bool hasCapacidade() => _capacidade != null;

  // "placa" field.
  String? _placa;
  String get placa => _placa ?? 'ABC-123';
  set placa(String? val) => _placa = val;

  bool hasPlaca() => _placa != null;

  // "estado" field.
  EstadoVeiculo? _estado;
  EstadoVeiculo get estado => _estado ?? EstadoVeiculo.DISPONIVEL;
  set estado(EstadoVeiculo? val) => _estado = val;

  bool hasEstado() => _estado != null;

  // "id" field.
  int? _id;
  int get id => _id ?? 1;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  static VeiculoStruct fromMap(Map<String, dynamic> data) => VeiculoStruct(
        capacidade: castToType<int>(data['capacidade']),
        placa: data['placa'] as String?,
        estado: data['estado'] is EstadoVeiculo
            ? data['estado']
            : deserializeEnum<EstadoVeiculo>(data['estado']),
        id: castToType<int>(data['id']),
      );

  static VeiculoStruct? maybeFromMap(dynamic data) =>
      data is Map ? VeiculoStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'capacidade': _capacidade,
        'placa': _placa,
        'estado': _estado?.serialize(),
        'id': _id,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'capacidade': serializeParam(
          _capacidade,
          ParamType.int,
        ),
        'placa': serializeParam(
          _placa,
          ParamType.String,
        ),
        'estado': serializeParam(
          _estado,
          ParamType.Enum,
        ),
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
      }.withoutNulls;

  static VeiculoStruct fromSerializableMap(Map<String, dynamic> data) =>
      VeiculoStruct(
        capacidade: deserializeParam(
          data['capacidade'],
          ParamType.int,
          false,
        ),
        placa: deserializeParam(
          data['placa'],
          ParamType.String,
          false,
        ),
        estado: deserializeParam<EstadoVeiculo>(
          data['estado'],
          ParamType.Enum,
          false,
        ),
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'VeiculoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is VeiculoStruct &&
        capacidade == other.capacidade &&
        placa == other.placa &&
        estado == other.estado &&
        id == other.id;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([capacidade, placa, estado, id]);
}

VeiculoStruct createVeiculoStruct({
  int? capacidade,
  String? placa,
  EstadoVeiculo? estado,
  int? id,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    VeiculoStruct(
      capacidade: capacidade,
      placa: placa,
      estado: estado,
      id: id,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

VeiculoStruct? updateVeiculoStruct(
  VeiculoStruct? veiculo, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    veiculo
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addVeiculoStructData(
  Map<String, dynamic> firestoreData,
  VeiculoStruct? veiculo,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (veiculo == null) {
    return;
  }
  if (veiculo.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && veiculo.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final veiculoData = getVeiculoFirestoreData(veiculo, forFieldValue);
  final nestedData = veiculoData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = veiculo.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getVeiculoFirestoreData(
  VeiculoStruct? veiculo, [
  bool forFieldValue = false,
]) {
  if (veiculo == null) {
    return {};
  }
  final firestoreData = mapToFirestore(veiculo.toMap());

  // Add any Firestore field values
  veiculo.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getVeiculoListFirestoreData(
  List<VeiculoStruct>? veiculos,
) =>
    veiculos?.map((e) => getVeiculoFirestoreData(e, true)).toList() ?? [];
