import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 1. Import your newly organized Login Page
import 'features/auth/screens/login_page.dart';

void main() async {
  // Keep the Firebase engine running!
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm 123',
      // Removes the red "DEBUG" banner in the top right corner
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        // Sets a default orange theme to match your Figma design
        primarySwatch: Colors.orange, 
      ),
      // 2. Tell the app to show your new page the second it opens!
      home: const LoginPage(), 
    );
  }
}