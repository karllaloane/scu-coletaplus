import '/components/lista_lixeiras_widget.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'rota_coleta_widget.dart' show RotaColetaWidget;
import 'package:flutter/material.dart';

class RotaColetaModel extends FlutterFlowModel<RotaColetaWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // Model for Lista_lixeiras component.
  late ListaLixeirasModel listaLixeirasModel;

  @override
  void initState(BuildContext context) {
    listaLixeirasModel = createModel(context, () => ListaLixeirasModel());
  }

  @override
  void dispose() {
    listaLixeirasModel.dispose();
  }
}
