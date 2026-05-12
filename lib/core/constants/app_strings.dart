class AppStrings {
  // App
  static const String appName = 'Aemo Finance';
  static const String tagline = 'Fast. Simple. Reliable.';

  // Supported Countries
  static const List<Map<String, String>> supportedCountries = [
    {
      'name': 'Belize',
      'code': 'BZ',
      'currency': 'BZD',
      'symbol': 'BZ\$',
      'flag': '🇧🇿',
      'area': '+501',
    },
    {
      'name': 'Panama',
      'code': 'PA',
      'currency': 'USD',
      'symbol': '\$',
      'flag': '🇵🇦',
      'area': '+507',
    },
    {
      'name': 'Oman',
      'code': 'OM',
      'currency': 'OMR',
      'symbol': 'OMR',
      'flag': '🇴🇲',
      'area': '+968',
    },
    {
      'name': 'Bahamas',
      'code': 'BS',
      'currency': 'BSD',
      'symbol': 'B\$',
      'flag': '🇧🇸',
      'area': '+1-242',
    },
    {
      'name': 'Barbados',
      'code': 'BB',
      'currency': 'BBD',
      'symbol': 'Bds\$',
      'flag': '🇧🇧',
      'area': '+1-246',
    },
    {
      'name': 'Trinidad & Tobago',
      'code': 'TT',
      'currency': 'TTD',
      'symbol': 'TT\$',
      'flag': '🇹🇹',
      'area': '+1-868',
    },
    {
      'name': 'Guyana',
      'code': 'GY',
      'currency': 'GYD',
      'symbol': 'G\$',
      'flag': '🇬🇾',
      'area': '+592',
    },
    {
      'name': 'Nigeria',
      'code': 'NG',
      'currency': 'NGN',
      'symbol': '₦',
      'flag': '🇳🇬',
      'area': '+234',
    },
    {
      'name': 'Jamaica',
      'code': 'JM',
      'currency': 'JMD',
      'symbol': 'J\$',
      'flag': '🇯🇲',
      'area': '+1-876',
    },
    {
      'name': 'South Africa',
      'code': 'ZA',
      'currency': 'ZAR',
      'symbol': 'R',
      'flag': '🇿🇦',
      'area': '+27',
    },
  ];

  // Banks per Country
  static const Map<String, List<String>> banksByCountry = {
    'BZ': [
      'Belize Bank',
      'Atlantic Bank',
      'Heritage Bank',
      'National Bank of Belize',
    ],
    'NG': [
      'Access Bank',
      'GTBank',
      'Zenith Bank',
      'First Bank of Nigeria',
    ],
    'OM': [
      'Bank Muscat',
      'National Bank of Oman',
      'Bank Dhofar',
      'Bank Sohar',
    ],
    'ZA': [
      "First Treasury Bank",
      'Standard Bank of South Africa',
      'Capitec Bank',
      ' Nedbank',
      'FNB (First National Bank)',
    ],
    'PA': [
      'Banco General',
      'Banco Nacional de Panamá',
      'Banistmo',
      'BAC International Bank',
    ],
    'BS': [
      'Bank of The Bahamas',
      'Commonwealth Bank',
      'Scotiabank Bahamas',
      'FirstCaribbean International Bank',
    ],
    'BB': [
      'Scotiabank Barbados',
      'FirstCaribbean International Bank',
      'Republic Bank Barbados',
      'Bajan Bank',
    ],
    'TT': [
      'Republic Bank',
      'First Citizens Bank',
      'Scotiabank Trinidad',
      'RBC Royal Bank',
    ],
    'GY': [
      'Demerara Bank',
      'Guyana Bank for Trade & Industry',
      'Republic Bank Guyana',
      'Citizens Bank Guyana',
    ],
    'JM': [
      'National Commercial Bank (NCB)',
      'Scotiabank Jamaica',
      'JMMB Bank',
      'First Global Bank',
    ],
  };

  // Loan Purposes
  static const List<String> loanPurposes = [
    'Personal',
    'Business',
    'Education',
    'Home Improvement',
    'Medical',
    'Vehicle',
    'Debt Consolidation',
    'Other',
  ];

  // Employment Status
  static const List<String> employmentStatuses = [
    'Formally Employed',
    'Government Employee',
    'Self Employed',
    'Business Owner',
  ];

  // Default/Fallback Loan Rates (months: APR %)
  static Map<int, double> get loanRates => defaultLoanRates;

  static const Map<int, double> defaultLoanRates = {
    3: 24.0,
    6: 18.0,
    12: 15.0,
    18: 12.0,
    24: 12.0,
    36: 12.0,
    48: 10.0,
    60: 10.0,
    72: 10.0,
    84: 9.0,
    96: 9.0,
    108: 8.0,
    120: 7.0,
  };

  // Localized Loan Rates per Country
  static const Map<String, Map<int, double>> localizedLoanRates = {
    // Belize (BZD) - High inflation, higher rates
    'BZ': {
      3: 25.0,
      6: 20.0,
      12: 18.0,
      18: 16.0,
      24: 16.0,
      36: 16.0,
      48: 14.0,
      60: 14.0,
      120: 8.0,
    },
    // Panama (USD) - Low inflation, competitive rates
    'PA': {
      3: 12.0,
      6: 10.0,
      12: 8.5,
      18: 8.0,
      24: 8.0,
      36: 7.5,
      48: 7.0,
      60: 7.0,
      120: 5.5,
    },
    // South Africa (ZAR) - Medium inflation
    'ZA': {
      3: 28.0,
      6: 22.0,
      12: 18.0,
      18: 15.0,
      24: 15.0,
      36: 14.0,
      48: 12.0,
      60: 12.0,
      120: 9.0,
    },
    // Oman (OMR) - Low rates
    'OM': {
      3: 10.0,
      6: 8.0,
      12: 6.5,
      18: 6.0,
      24: 6.0,
      36: 5.5,
      48: 5.0,
      60: 5.0,
      120: 4.0,
    },
    // Nigeria (NGN) - Higher inflation
    'NG': {
      3: 35.0,
      6: 30.0,
      12: 25.0,
      18: 20.0,
      24: 20.0,
      36: 18.0,
      48: 15.0,
      60: 15.0,
      120: 10.0,
    },
  };

  static Map<int, double> getLoanRates(String? countryCode) {
    if (countryCode == null) return defaultLoanRates;
    return localizedLoanRates[countryCode] ?? defaultLoanRates;
  }

  static const Map<int, double> loanMinimums = {
    3: 0,
    6: 0,
    12: 0,
    18: 0,
    24: 0,
    36: 0,
    48: 0,
    60: 40000,
    72: 60000,
    84: 60000,
    96: 120000,
    108: 120000,
    120: 120000,
  };
}
