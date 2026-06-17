import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'features/splash/screens/splash_page_1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    // Injecting the AuthController at the very top of the app tree
    ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm 123',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.orange, 
      ),
      home: const SplashPage1(), 
    );
  }
}
