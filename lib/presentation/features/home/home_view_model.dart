import 'package:flutter/foundation.dart';
import '../../../domain/usecases/get_gold_price.dart';
import '../../../domain/entities/gold_price_result.dart';

class HomeViewModel extends ChangeNotifier {
  final GetGoldPriceUseCase? _getGoldPriceUseCase;

  int _selectedIndex = 0;
  int _hadithIndex = 0;
  GoldPriceResult _goldPrice = GoldPriceResult.empty;
  bool _isLoadingGold = false;
  String? _goldError;

  HomeViewModel([this._getGoldPriceUseCase]);

  int get selectedIndex => _selectedIndex;
  int get hadithIndex => _hadithIndex;
  GoldPriceResult get goldPrice => _goldPrice;
  bool get isLoadingGold => _isLoadingGold;
  String? get goldError => _goldError;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void rotateHadith(int totalAhadith) {
    _hadithIndex = DateTime.now().day % totalAhadith;
    notifyListeners();
  }

  Future<void> refreshGoldPrice({String currency = 'USD'}) async {
    if (_getGoldPriceUseCase == null) return;
    _isLoadingGold = true;
    _goldError = null;
    notifyListeners();

    try {
      final result = await _getGoldPriceUseCase!.execute(currency);
      _goldPrice = result;
    } catch (e) {
      _goldError = e.toString();
    } finally {
      _isLoadingGold = false;
      notifyListeners();
    }
  }
}
