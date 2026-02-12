import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.employee,
  }) async {
    try {
      print('Starting registration...');
      print('Email: $email, Name: $name, Role: $role');
      
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Auth user created: ${result.user?.uid}');
      
      User? user = result.user;
      if (user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );
        
        print('Saving to Firestore...');
        print('User data: ${newUser.toMap()}');
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        
        print('Firestore save successful');
        return newUser;
      }
    } catch (e) {
      print('Register error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
    return null;
  }

  // Login user
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting login...');
      print('Email: $email');
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Auth login successful: ${result.user?.uid}');
      
      User? user = result.user;
      if (user != null) {
        print('Fetching user data from Firestore...');
        
        // Get user data from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        
        print('Firestore doc exists: ${doc.exists}');
        
        if (doc.exists) {
          UserModel userData = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          print('User data loaded: ${userData.name}');
          return userData;
        } else {
          print('Warning: User document not found in Firestore');
        }
      }
    } catch (e) {
      print('Login error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
    return null;
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Get user data error: $e');
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}