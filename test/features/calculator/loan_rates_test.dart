import 'package:flutter_test/flutter_test.dart';
import 'package:aemo_loan_app/core/constants/app_strings.dart';

void main() {
  group('Localized Loan Rates', () {
    test('should return localized rates for Panama (PA)', () {
      final rates = AppStrings.getLoanRates('PA');
      // Assuming Panama has lower rates as per plan
      expect(rates[3], lessThan(20.0));
      expect(rates[12], lessThan(15.0));
    });

    test('should return localized rates for South Africa (ZA)', () {
      final rates = AppStrings.getLoanRates('ZA');
      // South Africa might have higher rates
      expect(rates[3], greaterThanOrEqualTo(20.0));
    });

    test('should return default rates for unknown country code', () {
      final rates = AppStrings.getLoanRates('UNKNOWN');
      expect(rates, isNotEmpty);
      expect(rates[3], isNotNull);
    });

    test('should return default rates when country code is null', () {
      final rates = AppStrings.getLoanRates(null);
      expect(rates, isNotEmpty);
    });
  });
}
