import 'dart:async';

import 'package:logger/logger.dart';

import '../buscar_rota_page/buscar_rota_page_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'rota_coleta_model.dart';
export 'rota_coleta_model.dart';

class RotaColetaWidget extends StatefulWidget {
  const RotaColetaWidget({super.key});

  @override
  State<RotaColetaWidget> createState() => _RotaColetaWidgetState();
}

class _RotaColetaWidgetState extends State<RotaColetaWidget> {

  late RotaColetaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final logger = Logger();

  LatLng? currentUserLocationValue;
  String currentInstruction = 'Instrução';
  double nextCollectionDistance = 0.0;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RotaColetaModel());

    FFAppState().veiculo.estado = EstadoVeiculo.EM_ROTA;

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      currentUserLocationValue =
      await getCurrentUserLocation(defaultLocation: const LatLng(0.0, 0.0));

        _locationUpdateTimer =
            Timer.periodic(const Duration(seconds: 20), (timer) async {
              if (FFAppState().veiculo.estado == EstadoVeiculo.EM_ROTA) {
                await _sendLocationAndUpdateRoutes();
              } else {
                timer.cancel(); // Cancela o Timer se o estado não for mais EM_ROTA
              }
            });

    });

    getCurrentUserLocation(
        defaultLocation: const LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }

  Future<void> _sendLocationAndUpdateRoutes() async {

    _model.apiResultfv1 = await DescobrirLixeirasAPICall.call(
      authToken: FFAppState().userAcessToken,
      latitude: functions.getLatitude(currentUserLocationValue),
      longitude: functions.getLongitude(currentUserLocationValue),
      distanciaMaximaLixeira: 20,
      volumeMinimoLixeira: 0.7,
    );

    logger.d('CODE: ${_model.apiResultfv1?.response?.body}');

    final backendStatus = getJsonField(
      _model.apiResultfv1?.jsonBody,
      r'''$.backendStatus''',
    );

    //if ((_model.apiResultfv1?.succeeded ?? true)) {

    if ((_model.apiResultfv1?.succeeded ?? false)) {

      if (backendStatus != 'SEM_LIXEIRAS') {
          // Obtém a nova rota e as novas lixeiras recebidas
          final novaRota = (getJsonField(
            (_model.apiResultfv1?.jsonBody ?? ''),
            r'''$.polylines''',
            true,
          ) as List)
              .map<String>((s) => s.toString())
              .toList()
              .cast<String>();

          final novasLixeiras = (getJsonField(
            (_model.apiResultfv1?.jsonBody ?? ''),
            r'''$.lixeiras''',
            true,
          )!
              .toList()
              .map<LixeiraStruct?>(LixeiraStruct.maybeFromMap)
              .toList() as Iterable<LixeiraStruct?>)
              .withoutNulls
              .toList()
              .cast<LixeiraStruct>();

          //Verifica se a nova rota é diferente da
          final rotaMudou = FFAppState().rota.toString() != novaRota.toString();

          FFAppState().rota = novaRota;

          FFAppState().lixeiras = novasLixeiras;

          safeSetState(() {});

          if (rotaMudou) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Nova rota encontrada!',
                  style: TextStyle(
                    color: FlutterFlowTheme
                        .of(context)
                        .primaryText,
                  ),
                ),
                duration: const Duration(milliseconds: 6000),
                backgroundColor: FlutterFlowTheme
                    .of(context)
                    .secondary,
              ),
            );

            await _playNotificationSound();

          }
        }

    }
  }


  Future<void> _playNotificationSound() async {
    _model.soundPlayer1 ??= AudioPlayer();
    if (_model.soundPlayer1!.playing) {
      await _model.soundPlayer1!.stop();
    }
    _model.soundPlayer1!.setVolume(1.0);
    await _model.soundPlayer1!
        .setAsset('assets/audios/notification-sound-3-262896.mp3');
    await _model.soundPlayer1!.play();
  }

  @override
  void dispose() {

    FFAppState().rota.clear();
    FFAppState().lixeiras.clear();
    FFAppState().lixeirasVisitadas.clear();

    _locationUpdateTimer?.cancel();

    _model.soundPlayer1?.dispose();
    _model.soundPlayer2?.dispose();

    _model.dispose();

    super.dispose();
  }

  IconData _getInstructionIcon(String instruction) {
    if (instruction.contains('Vire à direita')) {
      return Icons.turn_right;
    } else if (instruction.contains('Vire à esquerda')) {
      return Icons.turn_left;
    } else if (instruction.contains('Siga em frente')) {
      return Icons.straight;
    } else {
      return Icons.help_outline; // Ícone genérico para instruções desconhecidas
    }
  }

  String _formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${distance.toStringAsFixed(0)} metros';
    }
  }

  Future<void> sendCollectionEvent(LixeiraStruct bin) async {
    try {
      logger.d('Caminhão ID: ${FFAppState().veiculo.id.toString()} + Lixeira ID: ${bin.id}');
      logger.d('Acess TOKEN: ${FFAppState().userAcessToken}');
      _model.apiResult24z = await InformarColetaAPICall.call(
        latitude: bin.latitude.toString(),
        longitude: bin.longitude.toString(),
        lixeiraId: bin.id ?? '',
        caminhaoId: FFAppState().veiculo.id.toString(),
        authToken: FFAppState().userAcessToken,
      );

      logger.e('CODE: ${_model.apiResult24z?.response?.statusCode}');

      if ((_model.apiResult24z?.succeeded ?? false)) {
        logger.d('[INFO] Evento de coleta enviado com sucesso para lixeira: ${bin.id}');

        // Toca som de confirmação
        _model.soundPlayer2 ??= AudioPlayer();
        if (_model.soundPlayer2!.playing) await _model.soundPlayer2!.stop();
        _model.soundPlayer2!.setVolume(1.0);
        await _model.soundPlayer2!
            .setAsset('assets/audios/ding-126626.mp3')
            .then((_) => _model.soundPlayer2!.play());
      }
    } catch (e) {
      logger.e('[ERROR] Falha ao enviar evento de coleta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () async {
                context.pop();
              },
            ),
            title: Text(
              'Rota de Coleta',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                  ),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 2.0,
          ),
          body: SafeArea(
            top: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * 1.202,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 747.0,
                            height: MediaQuery.sizeOf(context).height * 8.52,
                            decoration: const BoxDecoration(),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(0.0, -0.86),
                                  child: Container(
                                    width: 695.0,
                                    height: 1328.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                1.0,
                                        child: custom_widgets
                                            .CustomMapWithRouteAndBins(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              1.0,
                                          trashBinIconPath:
                                              'assets/images/icon-local-bin.png',
                                          initialZoom: 17.0,
                                          currentLocation:
                                              currentUserLocationValue!,
                                          polylinePoints: FFAppState().rota,
                                          trashBins: FFAppState().lixeiras,
                                          onSendCollectionEvent: sendCollectionEvent,
                                          onInstructionUpdate: (instruction) {
                                            setState(() {
                                              currentInstruction = instruction;
                                            });
                                          },
                                          onNextCollectionDistanceUpdate: (distance) {
                                            setState(() {
                                              nextCollectionDistance = distance;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                  tabletLandscape: false,
                                  desktop: false,
                                ))
                                  Align(
                                    alignment: const AlignmentDirectional(0.0, -0.86),
                                    child: Container(
                                      width: 695.0,
                                      height: 1328.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      child: Visibility(
                                        visible: responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                          tabletLandscape: false,
                                          desktop: false,
                                        ),
                                        child: FlutterFlowGoogleMap(
                                          controller:
                                              _model.googleMapsController,
                                          onCameraIdle: (latLng) =>
                                              _model.googleMapsCenter = latLng,
                                          initialLocation:
                                              _model.googleMapsCenter ??=
                                                  const LatLng(13.106061, -59.613158),
                                          markerColor: GoogleMarkerColor.violet,
                                          mapType: MapType.normal,
                                          style: GoogleMapStyle.standard,
                                          initialZoom: 14.0,
                                          allowInteraction: true,
                                          allowZoom: true,
                                          showZoomControls: true,
                                          showLocation: true,
                                          showCompass: false,
                                          showMapToolbar: false,
                                          showTraffic: false,
                                          centerMapOnMarkerTap: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (responsiveVisibility(
                                  context: context,
                                  phone: false,
                                  tablet: false,
                                  desktop: false,
                                ))
                                  Align(
                                    alignment: const AlignmentDirectional(0.0, 1.0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 8.0,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(0.0),
                                            bottomRight: Radius.circular(0.0),
                                            topLeft: Radius.circular(24.0),
                                            topRight: Radius.circular(24.0),
                                          ),
                                        ),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.916,
                                          height: 80.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(0.0),
                                              bottomRight: Radius.circular(0.0),
                                              topLeft: Radius.circular(24.0),
                                              topRight: Radius.circular(24.0),
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    14.0, 14.0, 14.0, 14.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 40.0,
                                                          height: 40.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFE3F2FD),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                          child: Icon(
                                                          _getInstructionIcon(currentInstruction),
                                                            color: Color(
                                                                0xFF1565C0),
                                                            size: 24.0,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                currentInstruction,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  0.0, 1.0),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        5.0),
                                                            child:
                                                                FFButtonWidget(
                                                                  onPressed: () async {
                                                                    currentUserLocationValue =
                                                                    await getCurrentUserLocation(
                                                                        defaultLocation:
                                                                        const LatLng(0.0,
                                                                            0.0));
                                                                    _model.apiResult2qp =
                                                                    await EstadoCaminhaoAPICall
                                                                        .call(
                                                                      authToken: FFAppState()
                                                                          .userAcessToken,
                                                                      idCaminhao:
                                                                      FFAppState()
                                                                          .veiculo
                                                                          .id,
                                                                      estadoCaminhao: "GUARDADO",
                                                                      latitude: functions
                                                                          .getLatitude(
                                                                          currentUserLocationValue),
                                                                      longitude: functions
                                                                          .getLongitude(
                                                                          currentUserLocationValue),
                                                                    );

                                                                    logger.e('CODE: ${_model.apiResult2qp?.response?.statusCode}');
                                                                    logger.e('CODE: ${_model.apiResult2qp?.response?.body}');

                                                                    if ((_model.apiResult2qp
                                                                        ?.succeeded ??
                                                                        true)) {
                                                                      FFAppState().rota.clear();
                                                                      FFAppState().lixeiras.clear();
                                                                      FFAppState().lixeirasVisitadas.clear();
                                                                      safeSetState(() {});
                                                                      await showDialog(
                                                                        context: context,
                                                                        builder:
                                                                            (alertDialogContext) {
                                                                          return AlertDialog(
                                                                            title: const Text(
                                                                                'Fim do trajeto'),
                                                                            content: const Text(
                                                                                'Sua coleta foi finalizada com sucesso!'),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () =>
                                                                                    Navigator.pop(
                                                                                        alertDialogContext),
                                                                                child: const Text(
                                                                                    'Ok'),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );

                                                                      context.pushReplacementNamed('BuscarRotaPage');

                                                                    } else {
                                                                      await showDialog(
                                                                        context: context,
                                                                        builder:
                                                                            (alertDialogContext) {
                                                                          return AlertDialog(
                                                                            title: const Text(
                                                                                'Erro'),
                                                                            content: const Text(
                                                                                'Não foi possível finalizar a coleta. Tente novamente mais tarde!'),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () =>
                                                                                    Navigator.pop(
                                                                                        alertDialogContext),
                                                                                child: const Text(
                                                                                    'Ok'),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    }

                                                                    safeSetState(() {});
                                                                  },
                                                              text:
                                                                  'Finalizar rota',
                                                              options:
                                                                  FFButtonOptions(
                                                                width: 150.0,
                                                                height: 40.0,
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                iconPadding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .warning,
                                                                textStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                                elevation: 0.0,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25.0),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ].divide(const SizedBox(
                                                          width: 16.0)),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 24.0)),
                                                ),
                                              ].divide(const SizedBox(height: 20.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (responsiveVisibility(
                                  context: context,
                                  tabletLandscape: false,
                                ))
                                  Align(
                                    alignment: const AlignmentDirectional(0.0, 1.0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 8.0,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(0.0),
                                            bottomRight: Radius.circular(0.0),
                                            topLeft: Radius.circular(24.0),
                                            topRight: Radius.circular(24.0),
                                          ),
                                        ),
                                        child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.916,
                                          height: 200.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(0.0),
                                              bottomRight: Radius.circular(0.0),
                                              topLeft: Radius.circular(24.0),
                                              topRight: Radius.circular(24.0),
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    14.0, 14.0, 14.0, 14.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        5.0,
                                                                        0.0),
                                                            child: Text(
                                                              'Próxima coleta em ',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Readex Pro',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ),
                                                          Text(
                                                            _formatDistance(nextCollectionDistance),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          1.0,
                                                  height: 1.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 40.0,
                                                          height: 40.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFE3F2FD),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                          child: Icon(
                                                          _getInstructionIcon(currentInstruction),
                                                            color: Color(
                                                                0xFF1565C0),
                                                            size: 24.0,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                               currentInstruction,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Readex Pro',
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ].divide(const SizedBox(
                                                          width: 16.0)),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 24.0)),
                                                ),
                                                Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          0.0, 1.0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 5.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        currentUserLocationValue =
                                                            await getCurrentUserLocation(
                                                                defaultLocation:
                                                                    const LatLng(0.0,
                                                                        0.0));
                                                        _model.apiResult2qp =
                                                            await EstadoCaminhaoAPICall
                                                                .call(
                                                          authToken: FFAppState()
                                                              .userAcessToken,
                                                          idCaminhao:
                                                              FFAppState()
                                                                  .veiculo
                                                                  .id,
                                                          estadoCaminhao: "GUARDADO",
                                                          latitude: functions
                                                              .getLatitude(
                                                                  currentUserLocationValue),
                                                          longitude: functions
                                                              .getLongitude(
                                                                  currentUserLocationValue),
                                                        );

                                                        logger.e('CODE: ${_model.apiResult2qp?.response?.statusCode}');
                                                        logger.e('CODE: ${_model.apiResult2qp?.response?.body}');

                                                        if ((_model.apiResult2qp
                                                                ?.succeeded ??
                                                            true)) {
                                                          FFAppState().rota.clear();
                                                          FFAppState().lixeiras.clear();
                                                          FFAppState().lixeirasVisitadas.clear();
                                                          safeSetState(() {});
                                                          await showDialog(
                                                            context: context,
                                                            builder:
                                                                (alertDialogContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Fim do trajeto'),
                                                                content: const Text(
                                                                    'Sua coleta foi finalizada com sucesso!'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            alertDialogContext),
                                                                    child: const Text(
                                                                        'Ok'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );

                                                        context.pushReplacementNamed('BuscarRotaPage');

                                                        } else {
                                                          await showDialog(
                                                            context: context,
                                                            builder:
                                                                (alertDialogContext) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Erro'),
                                                                content: const Text(
                                                                    'Não foi possível finalizar a coleta. Tente novamente mais tarde!'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            alertDialogContext),
                                                                    child: const Text(
                                                                        'Ok'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }

                                                        safeSetState(() {});
                                                      },
                                                      text: 'Finalizar rota',
                                                      options: FFButtonOptions(
                                                        width: 150.0,
                                                        height: 40.0,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .warning,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                        elevation: 0.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ].divide(const SizedBox(height: 20.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                ))
                  Expanded(
                    child: Container(
                      width: 100,
                      height: MediaQuery.sizeOf(context).height,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color(0x33000000),
                                offset: Offset(
                                  0,
                                  1,
                                ),
                                spreadRadius: 0,
                              )
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Lixeiras na Rota',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              FFAppState()
                                                  .lixeirasVisitadas
                                                  .length
                                                  .toString(),
                                              '0',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily: 'Readex Pro',
                                              color: FlutterFlowTheme.of(context).primary,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          Text(
                                            '/',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily: 'Readex Pro',
                                              color: FlutterFlowTheme.of(context).primary,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              FFAppState().lixeiras.length.toString(),
                                              '0',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily: 'Readex Pro',
                                              color: FlutterFlowTheme.of(context).primary,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                          Text(
                                            ' Visitadas',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily: 'Readex Pro',
                                              color: FlutterFlowTheme.of(context).primary,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Builder(
                                    builder: (context) {
                                      final listviewLixeiras = FFAppState().lixeiras.toList();
                                      return ListView.separated(
                                        padding: EdgeInsets.zero,
                                        primary: false,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: listviewLixeiras.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, listviewLixeirasIndex) {
                                          final listviewLixeirasItem =
                                          listviewLixeiras[listviewLixeirasIndex];
                                          return Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                12, 12, 12, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Icon(
                                                      Icons.delete_rounded,
                                                      color: () {
                                                        final porcentagem = (listviewLixeirasItem.volumeAtual /
                                                            listviewLixeirasItem.volumeMaximo) *
                                                            100;
                                                        if (porcentagem >=
                                                            90.0) {
                                                          return FlutterFlowTheme.of(context)
                                                              .error;
                                                        } else if ((porcentagem <
                                                            90.0) &&
                                                            (porcentagem >=
                                                                70.0)) {
                                                          return FlutterFlowTheme.of(context)
                                                              .tertiary;
                                                        } else {
                                                          return FlutterFlowTheme.of(context)
                                                              .primary;
                                                        }
                                                      }(),
                                                      size: 24,
                                                    ),
                                                    Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          listviewLixeirasItem.descricao
                                                              .maybeHandleOverflow(
                                                            maxChars: () {
                                                              if (MediaQuery.sizeOf(context)
                                                                  .width <
                                                                  kBreakpointSmall) {
                                                                return 10;
                                                              } else if (MediaQuery.sizeOf(
                                                                  context)
                                                                  .width <
                                                                  kBreakpointMedium) {
                                                              return 15;
                                                              } else if (MediaQuery.sizeOf(
                                                                  context)
                                                                  .width <
                                                                  kBreakpointLarge) {
                                                                return 20;
                                                              } else {
                                                                return 30;
                                                              }
                                                            }(),
                                                            replacement: '…',
                                                          ),
                                                          maxLines: 3,
                                                          style: FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .override(
                                                            fontFamily: 'Readex Pro',
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                        SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceAround,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                MainAxisSize.max,
                                                                children: [
                                                                  Text(
                                                                    'Volume: ',
                                                                    style: FlutterFlowTheme
                                                                        .of(context)
                                                                        .labelSmall
                                                                        .override(
                                                                      fontFamily:
                                                                      'Readex Pro',
                                                                      color: () {
                                                                        final porcentagem = (listviewLixeirasItem.volumeAtual /
                                                                            listviewLixeirasItem.volumeMaximo) *
                                                                            100;
                                                                        if (porcentagem >=
                                                                            90.0) {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .error;
                                                                        } else if ((porcentagem <
                                                                            90.0) &&
                                                                            (porcentagem >=
                                                                                70.0)) {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .tertiary;
                                                                        } else {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .primary;
                                                                        }
                                                                      }(),
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      '${((listviewLixeirasItem.volumeAtual / listviewLixeirasItem.volumeMaximo) * 100).toStringAsFixed(1)}%',
                                                                    style: FlutterFlowTheme
                                                                        .of(context)
                                                                        .labelSmall
                                                                        .override(
                                                                      fontFamily:
                                                                      'Readex Pro',
                                                                      color: () {
                                                                        final porcentagem = (listviewLixeirasItem.volumeAtual /
                                                                            listviewLixeirasItem.volumeMaximo) *
                                                                            100;
                                                                        if (porcentagem >=
                                                                            90.0) {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .error;
                                                                        } else if ((porcentagem <
                                                                            90.0) &&
                                                                            (porcentagem >=
                                                                                70.0)) {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .tertiary;
                                                                        } else {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .primary;
                                                                        }
                                                                      }(),
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '%',
                                                                    style: FlutterFlowTheme
                                                                        .of(context)
                                                                        .labelSmall
                                                                        .override(
                                                                      fontFamily:
                                                                      'Readex Pro',
                                                                      color: () {
                                                                        final porcentagem = (listviewLixeirasItem.volumeAtual /
                                                                            listviewLixeirasItem.volumeMaximo) *
                                                                            100;
                                                                        if (porcentagem >=
                                                                            90.0) {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .error;
                                                                        } else if ((porcentagem <
                                                                            90.0) &&
                                                                            (porcentagem >=
                                                                                70.0)) {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .tertiary;
                                                                        } else {
                                                                          return FlutterFlowTheme.of(
                                                                              context)
                                                                              .primary;
                                                                        }
                                                                      }(),
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(0, 0, 10, 0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize.max,
                                                                  children: [
                                                                    Text(
                                                                      'Peso: ',
                                                                      style:
                                                                      FlutterFlowTheme.of(
                                                                          context)
                                                                          .bodySmall
                                                                          .override(
                                                                        fontFamily:
                                                                        'Readex Pro',
                                                                        color: () {
                                                                          final porcentagem = (listviewLixeirasItem.volumeAtual /
                                                                              listviewLixeirasItem.volumeMaximo) *
                                                                              100;
                                                                          if (porcentagem >=
                                                                              90.0) {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .error;
                                                                          } else if ((porcentagem <
                                                                              90.0) &&
                                                                              (porcentagem >=
                                                                                  70.0)) {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .tertiary;
                                                                          } else {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .primary;
                                                                          }
                                                                        }(),
                                                                        letterSpacing:
                                                                        0.0,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      listviewLixeirasItem
                                                                          .volumeAtual
                                                                          .toString(),
                                                                      style:
                                                                      FlutterFlowTheme.of(
                                                                          context)
                                                                          .bodySmall
                                                                          .override(
                                                                        fontFamily:
                                                                        'Readex Pro',
                                                                        color: () {
                                                                          final porcentagem = (listviewLixeirasItem.volumeAtual /
                                                                              listviewLixeirasItem.volumeMaximo) *
                                                                              100;
                                                                          if (porcentagem >=
                                                                              90.0) {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .error;
                                                                          } else if ((porcentagem <
                                                                              90.0) &&
                                                                              (porcentagem >=
                                                                                  70.0)) {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .tertiary;
                                                                          } else {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .primary;
                                                                          }
                                                                        }(),
                                                                        letterSpacing:
                                                                        0.0,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'kg',
                                                                      style:
                                                                      FlutterFlowTheme.of(
                                                                          context)
                                                                          .bodySmall
                                                                          .override(
                                                                        fontFamily:
                                                                        'Readex Pro',
                                                                        color: () {
                                                                          final porcentagem = (listviewLixeirasItem.volumeAtual /
                                                                              listviewLixeirasItem.volumeMaximo) *
                                                                              100;
                                                                          if (porcentagem >=
                                                                              90.0) {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .error;
                                                                          } else if ((porcentagem <
                                                                              90.0) &&
                                                                              (porcentagem >=
                                                                                  70.0)) {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .tertiary;
                                                                          } else {
                                                                            return FlutterFlowTheme.of(
                                                                                context)
                                                                                .primary;
                                                                          }
                                                                        }(),
                                                                        letterSpacing:
                                                                        0.0,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ].divide(SizedBox(width: 10)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(SizedBox(width: 12)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(
                                                      4, 8, 4, 8),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: listviewLixeirasItem.isVisitada
                                                          ? FlutterFlowTheme.of(context)
                                                          .primary
                                                          : FlutterFlowTheme.of(context)
                                                          .alternate,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(8),
                                                      child: Text(
                                                        valueOrDefault<String>(
                                                          listviewLixeirasItem.isVisitada
                                                              ? 'Visitada'
                                                              : 'Em rota',
                                                          'Em rota',
                                                        ),
                                                        style: FlutterFlowTheme.of(context)
                                                            .labelSmall
                                                            .override(
                                                          fontFamily: 'Readex Pro',
                                                          color:
                                                          FlutterFlowTheme.of(context)
                                                              .info,
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 12)),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ].divide(SizedBox(height: 16)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
