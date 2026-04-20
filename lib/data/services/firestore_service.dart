import 'package:aemo_loan_app/data/models/withdrawal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/loan_application_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');

  CollectionReference get _applications =>
      _firestore.collection('loan_applications');

  Future<void> updateBankVerificationStatus({
    required String userId,
    required String bankAccountId,
    required BankVerificationStatus status,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final user = UserModel.fromMap(userDoc.data()!);

    final updatedAccounts = user.bankAccounts.map((account) {
      if (account.id == bankAccountId) {
        return BankAccount(
          id: account.id,
          bankName: account.bankName,
          accountNumber: account.accountNumber,
          accountName: account.accountName,
          verificationStatus: status,
        );
      }
      return account;
    }).toList();

    final updatedUser = user.copyWith(bankAccounts: updatedAccounts);
    await _firestore
        .collection('users')
        .doc(userId)
        .update(updatedUser.toMap());
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  // Save user
  Future<void> saveUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'Failed to save user profile. Please try again.';
    }
  }

  Future<LoanApplicationModel?> getLoanApplicationById(String id) async {
    final doc = await _firestore.collection('loan_applications').doc(id).get();
    if (!doc.exists) return null;
    return LoanApplicationModel.fromMap(
      doc.data()!,
    );
  }

  Future<void> updateVerificationStatus(
      String userId, VerificationStatus status) async {
    await _firestore.collection('users').doc(userId).update({
      'verificationStatus': status.name,
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteApplication(String applicationId) async {
    await _firestore
        .collection('loan_applications')
        .doc(applicationId)
        .delete();
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

  Future<void> saveKycDocuments({
    required String userId,
    required String idDocumentUrl,
    required String selfieUrl,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'idDocumentUrl': idDocumentUrl,
      'selfieUrl': selfieUrl,
      'verificationStatus': VerificationStatus.pending.name,
    });
  }

// Save a withdrawal
  Future<WithdrawalModel> createWithdrawal(WithdrawalModel withdrawal) async {
    final doc =
        await _firestore.collection('withdrawals').add(withdrawal.toMap());
    return WithdrawalModel.fromMap(withdrawal.toMap(), doc.id);
  }

// Fetch withdrawals for a user
  Future<List<WithdrawalModel>> getUserWithdrawals(String userId) async {
    final snapshot = await _firestore
        .collection('withdrawals')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WithdrawalModel.fromMap(doc.data(), doc.id))
        .toList();
  }

// Fetch all withdrawals (admin)
  Future<List<WithdrawalModel>> getAllWithdrawals() async {
    final snapshot = await _firestore
        .collection('withdrawals')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WithdrawalModel.fromMap(doc.data(), doc.id))
        .toList();
  }

// Update withdrawal status (admin)
  Future<void> updateWithdrawalStatus(
      String withdrawalId, WithdrawalStatus status) async {
    await _firestore.collection('withdrawals').doc(withdrawalId).update({
      'status': status.name,
      if (status == WithdrawalStatus.completed)
        'completedAt': DateTime.now().toIso8601String(),
    });
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
