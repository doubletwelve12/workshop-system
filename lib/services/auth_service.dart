import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user_model.dart';
import '../models/foreman_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential?> registerWithEmailAndPassword(String email, String password,{
    required String name,
    required String contactNumber,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // CREATE USER DOCUMENT IN FIRESTORE
    bool documentCreated = await createUserDocument(
      uid: userCredential.user!.uid,
      name: name,
      email: email,
      contactNumber: contactNumber,
      role: role,
    );
    
    if (!documentCreated) {
      // If Firestore document creation fails, delete the auth user
      await userCredential.user!.delete();
      throw Exception('Failed to create user profile. Registration cancelled.');
    }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      throw Exception(e.message); // Re-throw other exceptions
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // NEW METHODS FOR USER MANAGEMENT
  
  /// Get current logged-in user's app data (including role)
  // Future<AppUser?> getCurrentAppUser() async {
  //   try {
  //     final user = getCurrentUser();
  //     if (user == null) {
  //       print('No authenticated user found');
  //       return null;
  //     }
      
  //     print('Looking for user document with UID: ${user.uid}');
      
  //     final doc = await _firestore
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();
      
  //     if (!doc.exists) {
  //       print('Error: User data not found in Firestore for UID: ${user.uid}');
  //       print('User email: ${user.email}');
  //       print('Make sure to create user document in Firestore during registration');
  //       return null;
  //     }
      
  //     final data = doc.data();
  //     if (data == null) {
  //       print('Error: User document exists but data is null for UID: ${user.uid}');
  //       return null;
  //     }
      
  //     print('User data found: $data');
  //     return AppUser.fromFirestore(doc);
  //   } catch (e) {
  //     print('Error getting current app user: $e');
  //     return null;
  //   }
  // }
Future<AppUser?> getCurrentAppUser() async {
  try {
    final user = getCurrentUser();
    if (user == null) {
      print('❌ DEBUG: No authenticated user found');
      return null;
    }
    
    print('✅ DEBUG: Authenticated user UID: ${user.uid}');
    print('✅ DEBUG: User email: ${user.email}');
    print('✅ DEBUG: Looking for document in users/${user.uid}');
    
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    
    print('✅ DEBUG: Document exists: ${doc.exists}');
    
    if (!doc.exists) {
      print('❌ DEBUG: User data not found in Firestore for UID: ${user.uid}');
      
      // Check if document exists with different casing or path
      print('🔍 DEBUG: Checking if collection path is correct...');
      final collectionSnapshot = await _firestore.collection('users').limit(1).get();
      print('🔍 DEBUG: Users collection accessible: ${collectionSnapshot.docs.isNotEmpty}');
      
      // List first few documents to see what UIDs actually exist
      final allUsers = await _firestore.collection('users').limit(5).get();
      print('🔍 DEBUG: Sample UIDs in collection:');
      for (var docSnap in allUsers.docs) {
        print('  - ${docSnap.id}');
      }
      
      return null;
    }
    
    final data = doc.data();
    if (data == null) {
      print('❌ DEBUG: User document exists but data is null for UID: ${user.uid}');
      return null;
    }
    
    print('✅ DEBUG: User data retrieved successfully');
    print('✅ DEBUG: User role: ${data['role']}');
    print('✅ DEBUG: User name: ${data['name']}');
    
    return AppUser.fromFirestore(doc);
  } catch (e) {
    print('❌ DEBUG: Error in getCurrentAppUser: $e');
    print('❌ DEBUG: Error type: ${e.runtimeType}');
    return null;
  }
}


  /// Get current user's foreman data (if they are a foreman)
  Future<Foreman?> getCurrentForeman() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        print('No authenticated user found');
        return null;
      }
      
      // First check if user is a foreman
      final appUser = await getCurrentAppUser();
      if (appUser == null) {
        print('No app user data found');
        return null;
      }
      
      if (appUser.role != 'foreman') {
        print('User is not a foreman, role: ${appUser.role}');
        return null;
      }
      
      print('Looking for foreman data with userId: ${user.uid}');
      
      // Get foreman data
      final foremanQuery = await _firestore
          .collection('foremen')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      if (foremanQuery.docs.isEmpty) {
        print('No foreman document found for userId: ${user.uid}');
        return null;
      }
      
      print('Foreman data found');
      return Foreman.fromFirestore(foremanQuery.docs.first);
    } catch (e) {
      print('Error getting current foreman: $e');
      return null;
    }
  }

  /// Check if current user is workshop owner
  Future<bool> isWorkshopOwner() async {
    try {
      final appUser = await getCurrentAppUser();
      final isOwner = appUser?.role == 'workshop_owner';
      print('Is workshop owner: $isOwner (role: ${appUser?.role})');
      return isOwner;
    } catch (e) {
      print('Error checking workshop owner: $e');
      return false;
    }
  }

  /// Check if current user is foreman
  Future<bool> isForeman() async {
    try {
      final appUser = await getCurrentAppUser();
      final isForeman = appUser?.role == 'foreman';
      print('Is foreman: $isForeman (role: ${appUser?.role})');
      return isForeman;
    } catch (e) {
      print('Error checking foreman: $e');
      return false;
    }
  }

  /// Get current user's foreman ID
  Future<String?> getCurrentForemanId() async {
    try {
      final foreman = await getCurrentForeman();
      final foremanId = foreman?.id;
      print('Current foreman ID: $foremanId');
      return foremanId;
    } catch (e) {
      print('Error getting foreman ID: $e');
      return null;
    }
  }

  // HELPER METHOD: Create user document in Firestore
  Future<bool> createUserDocument({
  required String uid,
  required String name,
  required String email,
  required String contactNumber,
  required String role,
}) async {
  try {
    print('🔧 DEBUG: Creating user document...');
    print('🔧 DEBUG: UID: $uid');
    print('🔧 DEBUG: Name: $name');
    print('🔧 DEBUG: Email: $email');
    print('🔧 DEBUG: Contact: $contactNumber');
    print('🔧 DEBUG: Role: $role');
    
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'contactNumber': contactNumber,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ DEBUG: User document created successfully for UID: $uid');
    
    // Verify the document was actually created
    final verifyDoc = await _firestore.collection('users').doc(uid).get();
    print('✅ DEBUG: Document verification - exists: ${verifyDoc.exists}');
    if (verifyDoc.exists) {
      print('✅ DEBUG: Document data: ${verifyDoc.data()}');
    }
    
    return true;
  } catch (e) {
    print('❌ DEBUG: Error creating user document: $e');
    print('❌ DEBUG: Error type: ${e.runtimeType}');
    return false;
  }
}

  Future<void> deleteCurrentUserAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('This operation is sensitive and requires recent authentication. Please re-authenticate before trying again.');
      }
      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  Future<void> reauthenticateUser(String email, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception('Re-authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }
}
