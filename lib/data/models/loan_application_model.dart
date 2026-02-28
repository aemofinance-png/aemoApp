import 'package:equatable/equatable.dart';

enum LoanStatus { pending, approved, rejected }

class LoanApplicationModel extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String countryCode;
  final String employmentStatus;
  final String employer;
  final double monthlyIncome;
  final double loanAmount;
  final String loanPurpose;
  final int loanDuration;
  final String bankName;
  final String accountNumber;
  final List<String> documentUrls;
  final LoanStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? adminNote;

  const LoanApplicationModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.countryCode,
    required this.employmentStatus,
    required this.employer,
    required this.monthlyIncome,
    required this.loanAmount,
    required this.loanPurpose,
    required this.loanDuration,
    required this.bankName,
    required this.accountNumber,
    required this.documentUrls,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.adminNote,
  });

  factory LoanApplicationModel.fromMap(Map<String, dynamic> map) {
    return LoanApplicationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      countryCode: map['countryCode'] ?? 'BZ',
      employmentStatus: map['employmentStatus'] ?? '',
      employer: map['employer'] ?? '',
      monthlyIncome: (map['monthlyIncome'] ?? 0).toDouble(),
      loanAmount: (map['loanAmount'] ?? 0).toDouble(),
      loanPurpose: map['loanPurpose'] ?? '',
      loanDuration: map['loanDuration'] ?? 12,
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      status: LoanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LoanStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      reviewedAt:
          map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt']) : null,
      reviewedBy: map['reviewedBy'],
      adminNote: map['adminNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'countryCode': countryCode,
      'employmentStatus': employmentStatus,
      'employer': employer,
      'monthlyIncome': monthlyIncome,
      'loanAmount': loanAmount,
      'loanPurpose': loanPurpose,
      'loanDuration': loanDuration,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'documentUrls': documentUrls,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'adminNote': adminNote,
    };
  }

  LoanApplicationModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? countryCode,
    String? employmentStatus,
    String? employer,
    double? monthlyIncome,
    double? loanAmount,
    String? loanPurpose,
    int? loanDuration,
    String? bankName,
    String? accountNumber,
    List<String>? documentUrls,
    LoanStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? adminNote,
  }) {
    return LoanApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      employer: employer ?? this.employer,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      loanAmount: loanAmount ?? this.loanAmount,
      loanPurpose: loanPurpose ?? this.loanPurpose,
      loanDuration: loanDuration ?? this.loanDuration,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      documentUrls: documentUrls ?? this.documentUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      adminNote: adminNote ?? this.adminNote,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        phone,
        countryCode,
        employmentStatus,
        employer,
        monthlyIncome,
        loanAmount,
        loanPurpose,
        loanDuration,
        bankName,
        accountNumber,
        documentUrls,
        status,
        createdAt,
        reviewedAt,
        reviewedBy,
        adminNote,
      ];
}
