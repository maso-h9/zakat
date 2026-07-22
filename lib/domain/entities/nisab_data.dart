enum NisabMethod { global, official, custom }

class NisabComparison {
  final double globalNisabValue;
  final double activeNisabValue;
  final String activeMethod;
  final String currency;

  const NisabComparison({
    required this.globalNisabValue,
    required this.activeNisabValue,
    required this.activeMethod,
    required this.currency,
  });
}

class NisabHistoryEntry {
  final double value;
  final String method;
  final String currency;
  final DateTime date;

  const NisabHistoryEntry({
    required this.value,
    required this.method,
    required this.currency,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'value': value,
        'method': method,
        'currency': currency,
        'date': date.toIso8601String(),
      };

  factory NisabHistoryEntry.fromMap(Map<String, dynamic> m) =>
      NisabHistoryEntry(
        value: (m['value'] as num).toDouble(),
        method: m['method'] as String,
        currency: m['currency'] as String,
        date: DateTime.parse(m['date'] as String),
      );
}

class CountrySource {
  final String countryCode;
  final String sourceName;
  final String sourceUrl;
  final String description;

  const CountrySource({
    required this.countryCode,
    required this.sourceName,
    required this.sourceUrl,
    required this.description,
  });
}
