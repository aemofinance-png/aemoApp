import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String countryCode;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String role;
  final DateTime createdAt;

  const UserModel({
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
      countryCode: map['countryCode'] ?? 'BZ',
      role: map['role'] ?? 'user',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    String? email,
    String? phone,
    String? countryCode,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
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
        city,
        state,
        postalCode,
        role,
        createdAt,
      ];
}
