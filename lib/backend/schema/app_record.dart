import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AppRecord extends FirestoreRecord {
  AppRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "userName" field.
  String? _userName;
  String get userName => _userName ?? '';
  bool hasUserName() => _userName != null;

  // "isInRoute" field.
  bool? _isInRoute;
  bool get isInRoute => _isInRoute ?? false;
  bool hasIsInRoute() => _isInRoute != null;

  // "mainApp" field.
  String? _mainApp;
  String get mainApp => _mainApp ?? '';
  bool hasMainApp() => _mainApp != null;

  // "rota" field.
  List<String>? _rota;
  List<String> get rota => _rota ?? const [];
  bool hasRota() => _rota != null;

  // "lixeiras" field.
  List<LixeiraStruct>? _lixeiras;
  List<LixeiraStruct> get lixeiras => _lixeiras ?? const [];
  bool hasLixeiras() => _lixeiras != null;

  // "idCaminhao" field.
  int? _idCaminhao;
  int get idCaminhao => _idCaminhao ?? 0;
  bool hasIdCaminhao() => _idCaminhao != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  void _initializeFields() {
    _userName = snapshotData['userName'] as String?;
    _isInRoute = snapshotData['isInRoute'] as bool?;
    _mainApp = snapshotData['mainApp'] as String?;
    _rota = getDataList(snapshotData['rota']);
    _lixeiras = getStructList(
      snapshotData['lixeiras'],
      LixeiraStruct.fromMap,
    );
    _idCaminhao = castToType<int>(snapshotData['idCaminhao']);
    _timestamp = snapshotData['timestamp'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('app');

  static Stream<AppRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AppRecord.fromSnapshot(s));

  static Future<AppRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AppRecord.fromSnapshot(s));

  static AppRecord fromSnapshot(DocumentSnapshot snapshot) => AppRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AppRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AppRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AppRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AppRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAppRecordData({
  String? userName,
  bool? isInRoute,
  String? mainApp,
  int? idCaminhao,
  DateTime? timestamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userName': userName,
      'isInRoute': isInRoute,
      'mainApp': mainApp,
      'idCaminhao': idCaminhao,
      'timestamp': timestamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class AppRecordDocumentEquality implements Equality<AppRecord> {
  const AppRecordDocumentEquality();

  @override
  bool equals(AppRecord? e1, AppRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userName == e2?.userName &&
        e1?.isInRoute == e2?.isInRoute &&
        e1?.mainApp == e2?.mainApp &&
        listEquality.equals(e1?.rota, e2?.rota) &&
        listEquality.equals(e1?.lixeiras, e2?.lixeiras) &&
        e1?.idCaminhao == e2?.idCaminhao &&
        e1?.timestamp == e2?.timestamp;
  }

  @override
  int hash(AppRecord? e) => const ListEquality().hash([
        e?.userName,
        e?.isInRoute,
        e?.mainApp,
        e?.rota,
        e?.lixeiras,
        e?.idCaminhao,
        e?.timestamp
      ]);

  @override
  bool isValidKey(Object? o) => o is AppRecord;
}
