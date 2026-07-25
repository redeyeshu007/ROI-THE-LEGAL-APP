import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'package:get/route_manager.dart';
import 'package:login_signup/screens/wrapper.dart';
import 'package:login_signup/theme/theme.dart';

import 'package:login_signup/nucleus_config/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "REPLACE_WITH_YOUR_FIREBASE_API_KEY",
        authDomain: "myappconsi.firebaseapp.com",
        databaseURL: "https://myappconsi-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "myappconsi",
        storageBucket: "myappconsi.firebasestorage.app",
        messagingSenderId: "224150240249",
        appId: "1:224150240249:web:6d56af8ed528bd38ec1b28",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  // Initialize flutter_gemini before app starts
  Gemini.init(apiKey: 'REPLACE_WITH_YOUR_GEMINI_API_KEY');

  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ROI',
      translations: AppTranslations(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      theme: lightMode,
      home: const Wrapper(),
    );
  }
}
