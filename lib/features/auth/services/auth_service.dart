import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Added Firestore!

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- SIGN UP ---
  // 2. We now require the raw 'username' to be passed in so we can save it
  Future<UserCredential?> signUp(String email, String password, String username) async {
    try {
      // Step A: Create the secure login (The Bouncer)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step B: Create their game profile in the Database (The Filing Cabinet)
      if (userCredential.user != null) {
        // We use their highly secure UID as the name of their folder
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'username': username, // Their actual screen name!
          'createdAt': DateTime.now(),
          'levelsCompleted': 0, // Starting stats for a brand new player
          'badges': [], 
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- LOGIN ---
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Incorrect username or password.');
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  // --- SAVE PROGRESS & BADGES ---
  Future<void> saveBadgeAndProgress(String badgeName, int levelCompleted) async {
    try {
      // 1. Get the current logged-in user
      final User? user = _auth.currentUser;
      if (user == null) throw Exception("No user is currently logged in.");

      // 2. Fetch their current data to ensure we don't downgrade their level progress if they replay an old level
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      int currentLevels = userDoc.get('levelsCompleted') ?? 0;
      
      // Only increase the level count if the level they just beat is higher than their current score
      int newLevelCount = levelCompleted > currentLevels ? levelCompleted : currentLevels;

      // 3. Update the database
      await _firestore.collection('users').doc(user.uid).update({
        // arrayUnion appends the badge ONLY if it doesn't already exist in the list
        'badges': FieldValue.arrayUnion([badgeName]),
        'levelsCompleted': newLevelCount,
      });
      
      print("Successfully saved $badgeName and unlocked Level ${levelCompleted + 1}!");
      
    } catch (e) {
      print("Error saving progress: $e");
    }
  }
}