import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../firebase_options.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

// Firebase Initializer
final firebaseInitializerProvider = FutureProvider<FirebaseApp>((ref) async {
  return await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
});

// Auth Service
final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  // We don't necessarily NEED to watch firebaseInitializerProvider here 
  // if we guarantee initialization in main.dart or at the top of the widget tree,
  // but for safety during refreshes, we use .instance only after we know it's ready.
  return FirebaseAuthService(FirebaseAuth.instance);
});

// Firestore Service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

// Storage Service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

