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
    },
    {
      'name': 'Panama',
      'code': 'PA',
      'currency': 'USD',
      'symbol': '\$',
      'flag': '🇵🇦',
    },
    {
      'name': 'Bahamas',
      'code': 'BS',
      'currency': 'BSD',
      'symbol': 'B\$',
      'flag': '🇧🇸',
    },
    {
      'name': 'Barbados',
      'code': 'BB',
      'currency': 'BBD',
      'symbol': 'Bds\$',
      'flag': '🇧🇧',
    },
    {
      'name': 'Trinidad & Tobago',
      'code': 'TT',
      'currency': 'TTD',
      'symbol': 'TT\$',
      'flag': '🇹🇹',
    },
    {
      'name': 'Guyana',
      'code': 'GY',
      'currency': 'GYD',
      'symbol': 'G\$',
      'flag': '🇬🇾',
    },
    {
      'name': 'Jamaica',
      'code': 'JM',
      'currency': 'JMD',
      'symbol': 'J\$',
      'flag': '🇯🇲',
    },
    {
      'name': 'South Africa',
      'code': 'ZA',
      'currency': 'ZAR',
      'symbol': 'R',
      'flag': '🇿🇦',
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
    'ZA': [
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

  // Loan Durations in months
  static const Map<int, double> loanRates = {
    3: 35.0,
    6: 25.0,
    12: 20.0,
    18: 17.0,
    24: 17.0,
    36: 17.0,
    48: 15.0,
    60: 15.0,
    72: 15.0,
    84: 14.0,
    96: 14.0,
    108: 12.0,
    120: 11.0,
  };

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
