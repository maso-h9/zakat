import 'package:flutter/material.dart';
import '../../../domain/entities/wealth_data.dart';
import '../../../domain/usecases/calculate_zakat.dart';

class CalculatorViewModel extends ChangeNotifier {
  final CalculateZakatUseCase _calculateZakat;

  CalculatorViewModel(this._calculateZakat);

  double _money = 0;
  double _gold = 0;
  double _silver = 0;
  double _trade = 0;
  double _debtsOwed = 0;
  double _debtsReceive = 0;

  double get money => _money;
  double get gold => _gold;
  double get silver => _silver;
  double get trade => _trade;
  double get debtsOwed => _debtsOwed;
  double get debtsReceive => _debtsReceive;

  WealthData get _wealth => WealthData(
    savedMoney: _money,
    goldGrams: _gold,
    silverGrams: _silver,
    tradeGoods: _trade,
    debtsOwed: _debtsOwed,
    debtsToReceive: _debtsReceive,
  );

  void updateMoney(double v) { _money = v; notifyListeners(); }
  void updateGold(double v) { _gold = v; notifyListeners(); }
  void updateSilver(double v) { _silver = v; notifyListeners(); }
  void updateTrade(double v) { _trade = v; notifyListeners(); }
  void updateDebtsOwed(double v) { _debtsOwed = v; notifyListeners(); }
  void updateDebtsReceive(double v) { _debtsReceive = v; notifyListeners(); }

  double calculateTotal({
    required double goldPricePerGram,
    required double silverPricePerGram,
  }) {
    return _calculateZakat.calculateTotalWealth(
      wealth: _wealth,
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
    );
  }

  double calculateZakat({
    required double goldPricePerGram,
    required double silverPricePerGram,
  }) {
    final total = calculateTotal(
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
    );
    final nisab = _calculateZakat.calculateGoldNisab(goldPricePerGram);
    return _calculateZakat.calculateZakatDue(total, nisab);
  }

  bool hasReachedNisab({
    required double goldPricePerGram,
    required double silverPricePerGram,
  }) {
    final total = calculateTotal(
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
    );
    final nisab = _calculateZakat.calculateGoldNisab(goldPricePerGram);
    return _calculateZakat.hasReachedNisab(total, nisab);
  }

  void reset() {
    _money = 0;
    _gold = 0;
    _silver = 0;
    _trade = 0;
    _debtsOwed = 0;
    _debtsReceive = 0;
    notifyListeners();
  }
}
