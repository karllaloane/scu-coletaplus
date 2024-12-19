import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'rota_coleta_widget.dart' show RotaColetaWidget;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class RotaColetaModel extends FlutterFlowModel<RotaColetaWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Descobrir Lixeiras API)] action in RotaColeta widget.
  ApiCallResponse? apiResultfv1;
  AudioPlayer? soundPlayer1;
  // Stores action output result for [Backend Call - API (Informar Coleta API)] action in CustomMapWithRouteAndBins widget.
  ApiCallResponse? apiResult24z;
  AudioPlayer? soundPlayer2;
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // Stores action output result for [Backend Call - API (Estado Caminhao API)] action in Button widget.
  ApiCallResponse? apiResult2qp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
