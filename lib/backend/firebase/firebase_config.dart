import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCE5HcAEX_Be7_2Tci0Jtmtmu9K6evnWOY",
            authDomain: "coleta-plus-2xp90b.firebaseapp.com",
            projectId: "coleta-plus-2xp90b",
            storageBucket: "coleta-plus-2xp90b.firebasestorage.app",
            messagingSenderId: "458717794730",
            appId: "1:458717794730:web:8bf8a7c0abc13ab9f51bd3"));
  } else {
    await Firebase.initializeApp();
  }
}
