import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;
import '../schema/util/config.dart';

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class LoginAPICall {
  static Future<ApiCallResponse> call({
    String? login = '',
    String? senha = '',
  }) async {
    final ffApiRequestBody = '''
{
  "login": "${escapeStringForJson(login)}",
  "senha": "${escapeStringForJson(senha)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Login API',
      apiUrl: '${AppConfig.baseUrl}/publico/login',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic userAcessToken(dynamic response) => getJsonField(
        response,
        r'''$.access_token''',
      );
}

class ObterRotasAPICall {
  static Future<ApiCallResponse> call({
    String? authToken = '',
    String? latitude = '',
    String? longitude = '',
    int? kilometrosLimite = 10,
  }) async {
    final ffApiRequestBody = '''
{
  "latitude": "${escapeStringForJson(latitude)}",
  "longitude": "${escapeStringForJson(longitude)}",
  "kilometrosLimite": $kilometrosLimite
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Obter Rotas API',
      apiUrl: '${AppConfig.baseUrl}/caminhao/obter-rotas',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DescobrirLixeirasAPICall {
  static Future<ApiCallResponse> call({
    String? authToken = '',
    String? latitude = '',
    String? longitude = '',
    double? volumeMinimoLixeira = 0.7,
    int? distanciaMaximaLixeira = 20,
  }) async {
    final ffApiRequestBody = '''
{
  "latitude": "${escapeStringForJson(latitude)}",
  "longitude": "${escapeStringForJson(longitude)}",
  "distanciaMaximaLixeira": $distanciaMaximaLixeira,
  "volumeMinimoLixeira": $volumeMinimoLixeira
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Descobrir Lixeiras API',
      apiUrl: '${AppConfig.baseUrl}/caminhao/descobrir-lixeiras',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class InformarColetaAPICall {
  static Future<ApiCallResponse> call({
    String? latitude = '',
    String? longitude = '',
    String? lixeiraId = '',
    String? caminhaoId = '',
    String? authToken = '',
  }) async {
    final ffApiRequestBody = '''
{
  "latitude": "${escapeStringForJson(latitude)}",
  "longitude": "${escapeStringForJson(longitude)}",
  "lixeiraId": "${escapeStringForJson(lixeiraId)}",
  "caminhaoId": "${escapeStringForJson(caminhaoId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Informar Coleta API',
      apiUrl: '${AppConfig.baseUrl}/coleta/informar',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class EstadoCaminhaoAPICall {
  static Future<ApiCallResponse> call({
    String? authToken = '',
    int? idCaminhao,
    String? estadoCaminhao = '',
    String? latitude = '',
    String? longitude = '',
  }) async {
    final ffApiRequestBody = '''
{
  "idCaminhao": $idCaminhao,
  "estadoCaminhao": "${escapeStringForJson(estadoCaminhao)}",
  "latitude": "${escapeStringForJson(latitude)}",
  "longitude": "${escapeStringForJson(longitude)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Estado Caminhao API',
      apiUrl: '${AppConfig.baseUrl}/caminhao/registrar-estado-caminhao',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
