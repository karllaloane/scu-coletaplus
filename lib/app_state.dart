import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = const FlutterSecureStorage();
    await _safeInitAsync(() async {
      _userAcessToken =
          await secureStorage.getString('ff_userAcessToken') ?? _userAcessToken;
    });
    await _safeInitAsync(() async {
      _userName = await secureStorage.getString('ff_userName') ?? _userName;
    });
    await _safeInitAsync(() async {
      _senha = await secureStorage.getString('ff_senha') ?? _senha;
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_veiculo') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_veiculo') ?? '{}';
          _veiculo =
              VeiculoStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  String _userAcessToken = '';
  String get userAcessToken => _userAcessToken;
  set userAcessToken(String value) {
    _userAcessToken = value;
    secureStorage.setString('ff_userAcessToken', value);
  }

  void deleteUserAcessToken() {
    secureStorage.delete(key: 'ff_userAcessToken');
  }

  String _userName = '';
  String get userName => _userName;
  set userName(String value) {
    _userName = value;
    secureStorage.setString('ff_userName', value);
  }

  void deleteUserName() {
    secureStorage.delete(key: 'ff_userName');
  }

  String _senha = '';
  String get senha => _senha;
  set senha(String value) {
    _senha = value;
    secureStorage.setString('ff_senha', value);
  }

  void deleteSenha() {
    secureStorage.delete(key: 'ff_senha');
  }

  List<String> _rota = [];
  List<String> get rota => _rota;
  set rota(List<String> value) {
    _rota = value;
  }

  void addToRota(String value) {
    rota.add(value);
  }

  void removeFromRota(String value) {
    rota.remove(value);
  }

  void removeAtIndexFromRota(int index) {
    rota.removeAt(index);
  }

  void updateRotaAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    rota[index] = updateFn(_rota[index]);
  }

  void insertAtIndexInRota(int index, String value) {
    rota.insert(index, value);
  }

  List<LixeiraStruct> _Lixeiras = [];
  List<LixeiraStruct> get lixeiras => _Lixeiras;
  set lixeiras(List<LixeiraStruct> value) {
    _Lixeiras = value;
  }

  void addToLixeiras(LixeiraStruct value) {
    lixeiras.add(value);
  }

  void removeFromLixeiras(LixeiraStruct value) {
    lixeiras.remove(value);
  }

  void removeAtIndexFromLixeiras(int index) {
    lixeiras.removeAt(index);
  }

  void updateLixeirasAtIndex(
    int index,
    LixeiraStruct Function(LixeiraStruct) updateFn,
  ) {
    lixeiras[index] = updateFn(_Lixeiras[index]);
  }

  void insertAtIndexInLixeiras(int index, LixeiraStruct value) {
    lixeiras.insert(index, value);
  }

  VeiculoStruct _veiculo = VeiculoStruct.fromSerializableMap(jsonDecode(
      '{\"capacidade\":\"10\",\"placa\":\"ABC-1234\",\"estado\":\"DISPONIVEL\",\"id\":\"1\"}'));
  VeiculoStruct get veiculo => _veiculo;
  set veiculo(VeiculoStruct value) {
    _veiculo = value;
    secureStorage.setString('ff_veiculo', value.serialize());
  }

  void deleteVeiculo() {
    secureStorage.delete(key: 'ff_veiculo');
  }

  void updateVeiculoStruct(Function(VeiculoStruct) updateFn) {
    updateFn(_veiculo);
    secureStorage.setString('ff_veiculo', _veiculo.serialize());
  }

  List<LixeiraStruct> _lixeirasVisitadas = [];
  List<LixeiraStruct> get lixeirasVisitadas => _lixeirasVisitadas;
  set lixeirasVisitadas(List<LixeiraStruct> value) {
    _lixeirasVisitadas = value;
  }

  void addToLixeirasVisitadas(LixeiraStruct value) {
    lixeirasVisitadas.add(value);
  }

  void removeFromLixeirasVisitadas(LixeiraStruct value) {
    lixeirasVisitadas.remove(value);
  }

  void removeAtIndexFromLixeirasVisitadas(int index) {
    lixeirasVisitadas.removeAt(index);
  }

  void updateLixeirasVisitadasAtIndex(
    int index,
    LixeiraStruct Function(LixeiraStruct) updateFn,
  ) {
    lixeirasVisitadas[index] = updateFn(_lixeirasVisitadas[index]);
  }

  void insertAtIndexInLixeirasVisitadas(int index, LixeiraStruct value) {
    lixeirasVisitadas.insert(index, value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return const CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: const ListToCsvConverter().convert([value]));
}
