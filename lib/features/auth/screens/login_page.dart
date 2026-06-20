import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../home/screens/home_page.dart';

// Import your sign up page so the navigation button works!
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // The GlobalKey that controls and triggers the validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // 1. BACKGROUND LAYER 
          // ---------------------------------------------------------
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ---------------------------------------------------------
          // 2. FOREGROUND UI LAYER
          // ---------------------------------------------------------
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    // --- WOODEN SIGN WITH TEXT & OUTLINE ---
                    Stack(
                      alignment: Alignment.center, 
                      children: [
                        Image.asset(
                          'assets/images/wooden_sign.png',
                          height: 150, 
                          fit: BoxFit.contain,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0), 
                          child: Stack(
                            children: [
                              // Bottom Layer: Dark Brown Outline
                              Text(
                                'FARM 123',
                                style: GoogleFonts.sigmarOne( 
                                  fontSize: 42,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 8 
                                    ..color = const Color(0xFF4A3728), 
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(2, 4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              // Top Layer: Solid Peach Fill
                              Text(
                                'FARM 123',
                                style: GoogleFonts.sigmarOne( 
                                  fontSize: 42,
                                  color: const Color(0xFFFFD8B9), 
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- LOGIN HEADER ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Login',
                        style: GoogleFonts.fredoka( 
                          fontSize: 36,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- TRANSLUCENT LOGIN CARD ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.90), 
                        borderRadius: BorderRadius.circular(15), 
                        border: Border.all(
                          color: const Color(0xFFD9D9D9), 
                          width: 1,
                        ),
                      ),
                      
                      // 2. ADDED: Wrapped the inner Column in a Form widget
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            
                            // --- USERNAME FIELD ---
                            Text(
                              'Username', 
                              style: GoogleFonts.quicksand( 
                                fontWeight: FontWeight.w700, 
                                fontSize: 16,
                                color: const Color(0xFF4A3728), 
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 3. ADDED: Changed to TextFormField & Added Validator
                            TextFormField(
                              controller: _usernameController,
                              style: GoogleFonts.quicksand(fontSize: 16, color: Colors.black87),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username cannot be empty';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Value',
                                hintStyle: GoogleFonts.quicksand(
                                  color: const Color(0xFFB3B3B3), 
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFFFB347), width: 2), 
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- PASSWORD FIELD ---
                            Text(
                              'Password', 
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: const Color(0xFF4A3728),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 4. ADDED: Changed to TextFormField & Added Validator
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: GoogleFonts.quicksand(fontSize: 16, color: Colors.black87),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password cannot be empty';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Value',
                                hintStyle: GoogleFonts.quicksand(
                                  color: const Color(0xFFB3B3B3),
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFFFB347), width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // --- LOGIN BUTTON ---
                            Center(
                              child: SizedBox(
                                width: 158,
                                height: 51,
                                child: Consumer<AuthController>(
                                  builder: (context, authController, child) {
                                    return ElevatedButton(
                                      onPressed: authController.isLoading 
                                          ? null 
                                          : () async {
                                        if (_formKey.currentState!.validate()) {
                                          // 1. Send data to Firebase
                                          bool success = await authController.loginUser(
                                            _usernameController.text,
                                            _passwordController.text,
                                          );

                                          // 2. Handle the result
                                          if (success && context.mounted) {
                                          // Navigate to the home page, removing the back arrow so they can't accidentally go back to Login
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const HomePage()),
                                          );
                                        } else if (context.mounted){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(authController.errorMessage)),
                                          );
                                        }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFB347),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        elevation: 0,
                                      ),
                                      // 3. Swap text for a spinner if loading
                                      child: authController.isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF4A3728),
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : Text(
                                              'Login',
                                              style: GoogleFonts.quicksand(
                                                fontSize: 16,
                                                color: const Color(0xFF4A3728),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- CUSTOM DIVIDER ---
                            Center(
                              child: Container(
                                width: 259, 
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8DEF8), 
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // --- SIGN UP PROMPT ---
                            Center(
                              child: Text(
                                'NEW TO THE FARM?',
                                style: GoogleFonts.quicksand(
                                  color: Colors.black, 
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // --- SIGN UP BUTTON ---
                            Center(
                              child: SizedBox(
                                width: 158,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // 6. ADDED: Navigates to the Sign Up page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF2D06B), 
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16, 
                                      color: const Color(0xFF4A3728), 
                                      fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}
