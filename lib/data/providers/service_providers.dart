import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

// Auth Service
final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Firestore Service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Storage Service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
