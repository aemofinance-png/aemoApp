import 'package:equatable/equatable.dart';

enum VerificationStatus { unverified, pending, verified }

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String countryCode;
  final String countryName;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String role;
  final DateTime createdAt;
  final VerificationStatus verificationStatus;
  final String? idDocumentUrl;
  final String? selfieUrl;

  const UserModel({
    required this.countryName,
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
    required this.role,
    required this.createdAt,
    this.verificationStatus = VerificationStatus.unverified,
    this.idDocumentUrl,
    this.selfieUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      countryCode: map['countryCode'] ?? '',
      idDocumentUrl: map['idDocumentUrl'] as String?,
      selfieUrl: map['selfieUrl'] as String?,
      countryName: map['countryName'] as String? ?? 'Unknown',
      role: map['role'] ?? 'user',
      createdAt: DateTime.parse(map['createdAt']),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == map['verificationStatus'],
        orElse: () => VerificationStatus.unverified,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
      'countryName': countryName,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'role': role,
      'verificationStatus': verificationStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'idDocumentUrl': idDocumentUrl, // add this
      'selfieUrl': selfieUrl,
    };
  }

  UserModel copyWith({
    VerificationStatus? verificationStatus,
// and in the return:
    String? idDocumentUrl,
    String? selfieUrl,
    String? id,
    String? fullName,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    String? email,
    String? phone,
    String? countryCode,
    bool? isVerified,
    String? countryName,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      verificationStatus: verificationStatus ?? this.verificationStatus,
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      countryName: countryName ?? this.countryName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        countryCode,
        streetAddress,
        countryName,
        city,
        state,
        postalCode,
        role,
        createdAt,
      ];
}
