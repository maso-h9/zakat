class ZakatResult {
  final double totalWealth;
  final double zakatDue;
  final double goldNisabValue;
  final double silverNisabValue;
  final bool hasReachedNisab;
  final int daysUntilZakat;
  final String currency;

  const ZakatResult({
    required this.totalWealth,
    required this.zakatDue,
    required this.goldNisabValue,
    required this.silverNisabValue,
    required this.hasReachedNisab,
    required this.daysUntilZakat,
    required this.currency,
  });

  static const empty = ZakatResult(
    totalWealth: 0,
    zakatDue: 0,
    goldNisabValue: 0,
    silverNisabValue: 0,
    hasReachedNisab: false,
    daysUntilZakat: -1,
    currency: 'LYD',
  );
}
