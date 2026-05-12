import 'package:flutter_test/flutter_test.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';

void main() {
  group('Bank Account Deletion Logic', () {
    late UserModel user;
    const bankAccount1 = BankAccount(
      id: '1',
      bankName: 'Bank A',
      accountNumber: '123456',
      accountName: 'User One',
    );
    const bankAccount2 = BankAccount(
      id: '2',
      bankName: 'Bank B',
      accountNumber: '789012',
      accountName: 'User Two',
    );

    setUp(() {
      user = UserModel(
        id: 'user_123',
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '123456789',
        countryCode: 'BZ',
        countryName: 'Belize',
        streetAddress: '123 Main St',
        city: 'Belize City',
        state: 'Belize',
        postalCode: '00000',
        role: 'user',
        createdAt: DateTime.now(),
        bankAccounts: const [bankAccount1, bankAccount2],
      );
    });

    test('should remove bank account from the list when valid ID is provided',
        () {
      // Arrange
      const String accountIdToDelete = '1';

      // Act
      final updatedAccounts = user.bankAccounts
          .where((account) => account.id != accountIdToDelete)
          .toList();
      final updatedUser = user.copyWith(bankAccounts: updatedAccounts);

      // Assert
      expect(updatedUser.bankAccounts.length, 1);
      expect(updatedUser.bankAccounts.first.id, '2');
      expect(updatedUser.bankAccounts.any((a) => a.id == '1'), isFalse);
    });

    test('should not change the list when non-existent ID is provided', () {
      // Arrange
      const String accountIdToDelete = 'non_existent_id';

      // Act
      final updatedAccounts = user.bankAccounts
          .where((account) => account.id != accountIdToDelete)
          .toList();
      final updatedUser = user.copyWith(bankAccounts: updatedAccounts);

      // Assert
      expect(updatedUser.bankAccounts.length, 2);
      expect(updatedUser.bankAccounts.contains(bankAccount1), isTrue);
      expect(updatedUser.bankAccounts.contains(bankAccount2), isTrue);
    });

    test('should handle empty bank account list gracefully', () {
      // Arrange
      final emptyUser = user.copyWith(bankAccounts: []);
      const String accountIdToDelete = '1';

      // Act
      final updatedAccounts = emptyUser.bankAccounts
          .where((account) => account.id != accountIdToDelete)
          .toList();
      final updatedUser = emptyUser.copyWith(bankAccounts: updatedAccounts);

      // Assert
      expect(updatedUser.bankAccounts, isEmpty);
    });
  });
}
