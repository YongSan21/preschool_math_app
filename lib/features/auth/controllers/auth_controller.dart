import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // --- SIGN UP LOGIC ---
  Future<bool> signUpUser(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Tells the UI to show the loading spinner

    try {
      // Secretly append the dummy domain so Firebase accepts it as an email
      String formattedEmail = '$username@farm123.com'.replaceAll(' ', '').toLowerCase();
      
      await _authService.signUp(formattedEmail, password, username);
      
      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Sign up failed. Username might already be taken.';
      notifyListeners(); 
      return false; // Failed
    }
  }

  // --- LOGIN LOGIC ---
  Future<bool> loginUser(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      String formattedEmail = '$username@farm123.com'.replaceAll(' ', '').toLowerCase();
      
      await _authService.login(formattedEmail, password);
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login failed. Please check your username and password.';
      notifyListeners();
      return false;
    }
  }

  // --- LOGOUT LOGIC ---
  Future<void> logoutUser() async {
    await _authService.logout();
    notifyListeners();
  }
}
