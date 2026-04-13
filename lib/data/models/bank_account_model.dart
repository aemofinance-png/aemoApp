enum BankVerificationStatus { unverified, pending, verified }

class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final BankVerificationStatus verificationStatus;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.verificationStatus = BankVerificationStatus.unverified,
  });

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountName: map['accountName'] ?? '',
      verificationStatus: BankVerificationStatus.values.firstWhere(
        (e) => e.name == map['verificationStatus'],
        orElse: () => BankVerificationStatus.unverified,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'verificationStatus': verificationStatus.name,
    };
  }
}
