import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username,
          'createdAt': DateTime.now(),
          'progress': {
            'counting': {
              'levelsCompleted': 0,
              'badges': [],
            },
            'addition': {
              'levelsCompleted': 0,
              'badges': [],
            },
            'subtraction': {
              'levelsCompleted': 0,
              'badges': [],
            },
          },
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> saveBadgeAndProgress(
    String module,
    String badgeName,
    int levelCompleted,
  ) async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        throw Exception('No user is currently logged in.');
      }

      final DocumentReference<Map<String, dynamic>> userRef =
          _firestore.collection('users').doc(user.uid);

      final DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef.get();

      int currentLevels = 0;
      List<dynamic> badgesToSave = [badgeName];

      if (userDoc.exists) {
        final data = userDoc.data();

        final progress = data == null
            ? null
            : data['progress'] as Map<String, dynamic>?;
        final moduleProgress = progress?[module] as Map<String, dynamic>?;

        final moduleLevelsCompleted = moduleProgress?['levelsCompleted'];
        final legacyLevelsCompleted =
            module == 'counting' && data != null ? data['levelsCompleted'] : null;
        final legacyBadges =
            module == 'counting' && data != null ? data['badges'] : null;

        if (moduleLevelsCompleted is int) {
          currentLevels = moduleLevelsCompleted;
        } else if (legacyLevelsCompleted is int) {
          currentLevels = legacyLevelsCompleted;
        }

        if (legacyBadges is List) {
          badgesToSave = [...legacyBadges, badgeName];
        }
      }

      final int newLevelCount =
          levelCompleted > currentLevels ? levelCompleted : currentLevels;

      await userRef.set({
        'progress': {
          module: {
            'levelsCompleted': newLevelCount,
            'badges': FieldValue.arrayUnion(badgesToSave),
          },
        },
      }, SetOptions(merge: true));

      print(
        'Successfully saved $badgeName for $module and unlocked Level ${levelCompleted + 1}!',
      );
    } catch (e) {
      print('Error saving progress: $e');
    }
  }
}
