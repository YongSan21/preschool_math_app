import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SIGN UP HEADER ---
                    Text(
                      'Sign Up',
                      style: GoogleFonts.fredoka(
                        fontSize: 36,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- TRANSLUCENT SIGN UP CARD ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
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
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username cannot be empty';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter your username',
                                hintStyle: GoogleFonts.quicksand(
                                  color: const Color(0xFFB3B3B3),
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD9D9D9),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD9D9D9),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFFB347),
                                    width: 2,
                                  ),
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
                              obscureText: _obscurePassword,
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
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
                                hintText: 'Enter at least 6 characters',
                                hintStyle: GoogleFonts.quicksand(
                                  color: const Color(0xFFB3B3B3),
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: const Color(0xFF4A3728),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD9D9D9),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD9D9D9),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFFB347),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // --- SIGN UP BUTTON ---
                            Center(
                              child: SizedBox(
                                width: 158,
                                height: 52,
                                child: Consumer<AuthController>(
                                  // Listens to the controller
                                  builder: (context, authController, child) {
                                    return ElevatedButton(
                                      onPressed: authController.isLoading
                                          ? null // Disables button while loading
                                          : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // 1. Send data to Firebase
                                                bool
                                                success = await authController
                                                    .signUpUser(
                                                      _usernameController.text,
                                                      _passwordController.text,
                                                    );

                                                // 2. Handle the result
                                                if (success &&
                                                    context.mounted) {
                                                  _showSuccessDialog(); // Show the horse!
                                                } else if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        authController
                                                            .errorMessage,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFF2D06B,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
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
                                              'Sign Up',
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

  // --- SUCCESS POP-UP DIALOG ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Forces the user to tap the button to close it
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Makes the background invisible
          elevation: 0,
          child: Container(
            width: 334,
            height: 197,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // --- TEXT & BUTTON (Left Side) ---
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 30, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width:
                            170, // Keeps the text from crashing into the horse
                        child: Text(
                          'You signed up\nsuccessfully!',
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // 1. Close the Dialog
                            Navigator.of(context).pop();
                            // 2. Go back to the Login Page
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF2D06B,
                            ), // Yellow from Figma
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Continue Login',
                            maxLines: 1,
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4A3728),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- HORSE IMAGE (Right Side) ---
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Image.asset(
                    'assets/images/horse.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
