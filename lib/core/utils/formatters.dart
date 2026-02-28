import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class Formatters {
  // Get currency symbol by country code
  static String getCurrencySymbol(String countryCode) {
    final country = AppStrings.supportedCountries.firstWhere(
      (c) => c['code'] == countryCode,
      orElse: () => {'symbol': '\$'},
    );
    return country['symbol']!;
  }

  // Get currency code by country code
  static String getCurrencyCode(String countryCode) {
    final country = AppStrings.supportedCountries.firstWhere(
      (c) => c['code'] == countryCode,
      orElse: () => {'currency': 'USD'},
    );
    return country['currency']!;
  }

  // Format currency based on country
  static String currency(double amount, String countryCode) {
    final symbol = getCurrencySymbol(countryCode);
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Date
  static String date(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Date with time
  static String dateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy – hh:mm a').format(date);
  }

  // Loan duration
  static String duration(int months) {
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    final remaining = months % 12;
    if (remaining == 0) return '$years ${years == 1 ? 'year' : 'years'}';
    return '$years ${years == 1 ? 'year' : 'years'} $remaining months';
  }
}
