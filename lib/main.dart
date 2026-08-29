import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  // Ensure Flutter engine bindings are loaded
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        // On Android/iOS, initialize using native packaged google-services configurations
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    debugPrint("Firebase initialization skipped/failed: $e");
  }
  
  runApp(
    const ProviderScope(
      child: MeetlyApp(),
    ),
  );
}
