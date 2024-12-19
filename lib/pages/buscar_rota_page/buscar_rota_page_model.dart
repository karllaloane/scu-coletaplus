import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'buscar_rota_page_widget.dart' show BuscarRotaPageWidget;
import 'package:flutter/material.dart';

class BuscarRotaPageModel extends FlutterFlowModel<BuscarRotaPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Backend Call - API (Obter Rotas API)] action in Button widget.
  ApiCallResponse? apiResultcp9;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
