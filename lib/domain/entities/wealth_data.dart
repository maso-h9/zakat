class WealthData {
  final double savedMoney;
  final double goldGrams;
  final double silverGrams;
  final double tradeGoods;
  final double debtsOwed;
  final double debtsToReceive;

  const WealthData({
    this.savedMoney = 0,
    this.goldGrams = 0,
    this.silverGrams = 0,
    this.tradeGoods = 0,
    this.debtsOwed = 0,
    this.debtsToReceive = 0,
  });

  WealthData copyWith({
    double? savedMoney,
    double? goldGrams,
    double? silverGrams,
    double? tradeGoods,
    double? debtsOwed,
    double? debtsToReceive,
  }) {
    return WealthData(
      savedMoney: savedMoney ?? this.savedMoney,
      goldGrams: goldGrams ?? this.goldGrams,
      silverGrams: silverGrams ?? this.silverGrams,
      tradeGoods: tradeGoods ?? this.tradeGoods,
      debtsOwed: debtsOwed ?? this.debtsOwed,
      debtsToReceive: debtsToReceive ?? this.debtsToReceive,
    );
  }

  static const empty = WealthData();

  Map<String, dynamic> toMap() => {
        'money': savedMoney,
        'gold': goldGrams,
        'silver': silverGrams,
        'trade': tradeGoods,
        'debtsOwed': debtsOwed,
        'debtsReceive': debtsToReceive,
      };

  factory WealthData.fromMap(Map<String, dynamic> m) => WealthData(
        savedMoney: (m['money'] as num?)?.toDouble() ?? 0,
        goldGrams: (m['gold'] as num?)?.toDouble() ?? 0,
        silverGrams: (m['silver'] as num?)?.toDouble() ?? 0,
        tradeGoods: (m['trade'] as num?)?.toDouble() ?? 0,
        debtsOwed: (m['debtsOwed'] as num?)?.toDouble() ?? 0,
        debtsToReceive: (m['debtsReceive'] as num?)?.toDouble() ?? 0,
      );
}
