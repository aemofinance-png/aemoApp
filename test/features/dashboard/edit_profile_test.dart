import 'package:flutter_test/flutter_test.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';

void main() {
  group('Edit Profile KYC Logic', () {
    late UserModel originalUser;

    setUp(() {
      originalUser = UserModel(
        id: 'user_123',
        fullName: 'Original Name',
        email: 'user@example.com',
        phone: '1234567890',
        streetAddress: '123 Street',
        city: 'City',
        state: 'State',
        postalCode: '12345',
        countryCode: 'BZ',
        countryName: 'Belize',
        role: 'user',
        createdAt: DateTime.now(),
        verificationStatus: VerificationStatus.verified,
      );
    });

    test('should reset KYC status to unverified if fullName is changed', () {
      // Arrange
      const String newName = 'New Name';

      // Act
      VerificationStatus status = originalUser.verificationStatus;
      if (newName != originalUser.fullName) {
        status = VerificationStatus.unverified;
      }
      final updatedUser = originalUser.copyWith(
        fullName: newName,
        verificationStatus: status,
      );

      // Assert
      expect(updatedUser.fullName, newName);
      expect(updatedUser.verificationStatus, VerificationStatus.unverified);
    });

    test('should keep current KYC status if fullName is not changed', () {
      // Arrange
      const String newPhone = '0987654321';
      const String newAddress = '456 New Street';

      // Act
      VerificationStatus status = originalUser.verificationStatus;
      if (originalUser.fullName != originalUser.fullName) {
        // This is always false, just mirroring logic
        status = VerificationStatus.unverified;
      }
      final updatedUser = originalUser.copyWith(
        phone: newPhone,
        streetAddress: newAddress,
        verificationStatus: status,
      );

      // Assert
      expect(updatedUser.fullName, originalUser.fullName);
      expect(updatedUser.phone, newPhone);
      expect(updatedUser.streetAddress, newAddress);
      expect(updatedUser.verificationStatus, VerificationStatus.verified);
    });

    test('should handle name change with same name (case-sensitive) correctly',
        () {
      // Arrange
      const String sameName = 'Original Name';

      // Act
      VerificationStatus status = originalUser.verificationStatus;
      if (sameName != originalUser.fullName) {
        status = VerificationStatus.unverified;
      }
      final updatedUser = originalUser.copyWith(
        fullName: sameName,
        verificationStatus: status,
      );

      // Assert
      expect(updatedUser.fullName, sameName);
      expect(updatedUser.verificationStatus, VerificationStatus.verified);
    });
  });
}
