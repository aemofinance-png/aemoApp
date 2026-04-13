// lib/data/models/withdrawal_model.dart

enum WithdrawalStatus { pending, processing, completed, failed }

class WithdrawalModel {
  final String id;
  final String userId;
  final String applicationId;
  final String userName; // ✅ add this
  final double amount;
  final String bankName;
  final String accountNumber;
  final String? documentUrl;
  final WithdrawalStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WithdrawalModel({
    required this.id,
    required this.userId,
    required this.applicationId,
    required this.userName, // ✅ add this
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    this.documentUrl,
    this.status = WithdrawalStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  factory WithdrawalModel.fromMap(Map<String, dynamic> map, String id) {
    return WithdrawalModel(
      id: id,
      userId: map['userId'] ?? '',
      applicationId: map['applicationId'] ?? '',
      userName: map['userName'] ?? 'Unknown', // ✅ add this
      amount: (map['amount'] as num).toDouble(),
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      documentUrl: map['documentUrl'],
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => WithdrawalStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'applicationId': applicationId,
      'userName': userName, // ✅ add this
      'amount': amount,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'documentUrl': documentUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
