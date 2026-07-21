class ZakatRecord {
  final int year;
  final double amount;
  final double wealth;
  final DateTime date;
  final String note;

  const ZakatRecord({
    required this.year,
    required this.amount,
    required this.wealth,
    required this.date,
    this.note = '',
  });

  ZakatRecord copyWith({
    int? year,
    double? amount,
    double? wealth,
    DateTime? date,
    String? note,
  }) {
    return ZakatRecord(
      year: year ?? this.year,
      amount: amount ?? this.amount,
      wealth: wealth ?? this.wealth,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'year': year,
        'amount': amount,
        'wealth': wealth,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory ZakatRecord.fromMap(Map<String, dynamic> m) => ZakatRecord(
        year: m['year'] as int,
        amount: (m['amount'] as num).toDouble(),
        wealth: (m['wealth'] as num).toDouble(),
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String? ?? '',
      );
}
