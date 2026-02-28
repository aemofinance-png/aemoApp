import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/loan_application_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');

  CollectionReference get _applications =>
      _firestore.collection('loan_applications');

  // Save user
  Future<void> saveUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'Failed to save user profile. Please try again.';
    }
  }

  // Get user
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user profile. Please try again.';
    }
  }

  // Save loan application
  Future<void> saveApplication(LoanApplicationModel application) async {
    try {
      await _applications.doc(application.id).set(application.toMap());
    } catch (e) {
      throw 'Failed to submit application. Please try again.';
    }
  }

  // Get applications for a specific user
  Future<List<LoanApplicationModel>> getUserApplications(String userId) async {
    try {
      final snapshot = await _applications
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              LoanApplicationModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to fetch applications. Please try again.';
    }
  }

  // Get all applications (admin only)
  Future<List<LoanApplicationModel>> getAllApplications() async {
    try {
      final snapshot =
          await _applications.orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map((doc) =>
              LoanApplicationModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to fetch applications. Please try again.';
    }
  }

  // Update application status (admin only)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required LoanStatus status,
    required String reviewedBy,
    String? adminNote,
  }) async {
    try {
      await _applications.doc(applicationId).update({
        'status': status.name,
        'reviewedBy': reviewedBy,
        'reviewedAt': DateTime.now().toIso8601String(),
        'adminNote': adminNote,
      });
    } catch (e) {
      throw 'Failed to update application. Please try again.';
    }
  }
}
