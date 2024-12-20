import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';

class FirebaseStateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referência para o documento do usuário
  DocumentReference getUserDoc(String username) {
    return _firestore.collection('userStates').doc(username);
  }

  // Salvar estado no Firebase
  Future<void> saveState({
    required String username,
    required VeiculoStruct veiculo,
    required List<LixeiraStruct> lixeiras,
    required List<String> rotas,
    required bool emRota,
  }) async {
    final userDoc = getUserDoc(username);

    await userDoc.set({
      'veiculo': veiculo.toMap(),
      'lixeiras': lixeiras.map((l) => l.toMap()).toList(),
      'rotas': rotas,
      'emRota': emRota,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Verificar estado inicial
  Future<Map<String, dynamic>?> checkInitialState(String username) async {
    final userDoc = getUserDoc(username);
    final snapshot = await userDoc.get();

    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Stream para mudanças no estado
  Stream<Map<String, dynamic>?> watchState(String username) {
    return getUserDoc(username).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  // Atualizar campo específico
  Future<void> updateField(String username, String field, dynamic value) async {
    await getUserDoc(username).update({
      field: value,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}