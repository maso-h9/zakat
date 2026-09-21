class CurrencyModel {
  final String code;
  final String symbol;
  final String name;

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<CurrencyModel> currencies = [
  CurrencyModel(code: 'LYD', symbol: 'د.ل', name: 'دينار ليبي'),
  CurrencyModel(code: 'SAR', symbol: 'ر.س', name: 'ريال سعودي'),
  CurrencyModel(code: 'AED', symbol: 'د.إ', name: 'درهم إماراتي'),
  CurrencyModel(code: 'EGP', symbol: 'ج.م', name: 'جنيه مصري'),
  CurrencyModel(code: 'USD', symbol: '\$', name: 'دولار أمريكي'),
  CurrencyModel(code: 'EUR', symbol: '€', name: 'يورو'),
  CurrencyModel(code: 'GBP', symbol: '£', name: 'جنيه إسترليني'),
  CurrencyModel(code: 'KWD', symbol: 'د.ك', name: 'دينار كويتي'),
  CurrencyModel(code: 'QAR', symbol: 'ر.ق', name: 'ريال قطري'),
  CurrencyModel(code: 'JOD', symbol: 'د.أ', name: 'دينار أردني'),
  CurrencyModel(code: 'MAD', symbol: 'د.م', name: 'درهم مغربي'),
  CurrencyModel(code: 'TND', symbol: 'د.ت', name: 'دينار تونسي'),
];
