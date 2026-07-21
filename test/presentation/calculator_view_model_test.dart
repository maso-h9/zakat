import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_app/presentation/features/calculator/calculator_view_model.dart';
import 'package:zakat_app/domain/usecases/calculate_zakat.dart';

void main() {
  late CalculateZakatUseCase useCase;

  setUp(() {
    useCase = CalculateZakatUseCase();
  });

  group('CalculatorViewModel', () {
    late CalculatorViewModel viewModel;

    setUp(() {
      viewModel = CalculatorViewModel(useCase);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initial values are zero', () {
      expect(viewModel.money, 0);
      expect(viewModel.gold, 0);
      expect(viewModel.silver, 0);
      expect(viewModel.trade, 0);
      expect(viewModel.debtsOwed, 0);
      expect(viewModel.debtsReceive, 0);
    });

    test('updateMoney modifies money', () {
      viewModel.updateMoney(50000);
      expect(viewModel.money, 50000);
    });

    test('updateGold modifies gold', () {
      viewModel.updateGold(100);
      expect(viewModel.gold, 100);
    });

    test('updateSilver modifies silver', () {
      viewModel.updateSilver(200);
      expect(viewModel.silver, 200);
    });

    test('updateTrade modifies trade', () {
      viewModel.updateTrade(30000);
      expect(viewModel.trade, 30000);
    });

    test('updateDebtsOwed modifies debtsOwed', () {
      viewModel.updateDebtsOwed(10000);
      expect(viewModel.debtsOwed, 10000);
    });

    test('updateDebtsReceive modifies debtsReceive', () {
      viewModel.updateDebtsReceive(5000);
      expect(viewModel.debtsReceive, 5000);
    });

    test('calculateTotal with savings only', () {
      viewModel.updateMoney(100000);
      final total = viewModel.calculateTotal(
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      expect(total, 100000);
    });

    test('calculateTotal with gold + savings', () {
      viewModel.updateMoney(20000);
      viewModel.updateGold(100);
      final total = viewModel.calculateTotal(
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      // 20000 + 100*1000 = 120000
      expect(total, 120000);
    });

    test('calculateTotal with all components', () {
      viewModel.updateMoney(50000);
      viewModel.updateGold(50);
      viewModel.updateSilver(200);
      viewModel.updateTrade(30000);
      viewModel.updateDebtsOwed(10000);
      viewModel.updateDebtsReceive(5000);
      final total = viewModel.calculateTotal(
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      // 50000 + 50000 + 200 + 30000 - 10000 + 5000 = 125200
      expect(total, closeTo(125200, 0.1));
    });

    test('calculateTotal never goes negative', () {
      viewModel.updateMoney(100);
      viewModel.updateDebtsOwed(5000);
      final total = viewModel.calculateTotal(
        goldPricePerGram: 0,
        silverPricePerGram: 0,
      );
      expect(total, 0);
    });

    test('calculateZakat returns 2.5% when above nisab', () {
      viewModel.updateMoney(200000);
      final zakat = viewModel.calculateZakat(
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      expect(zakat, 5000);
    });

    test('calculateZakat returns 0 when below nisab', () {
      viewModel.updateMoney(50000);
      final zakat = viewModel.calculateZakat(
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      expect(zakat, 0);
    });

    test('hasReachedNisab with zero wealth', () {
      final reached = viewModel.hasReachedNisab(
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      expect(reached, isFalse);
    });

    test('hasReachedNisab with sufficient wealth', () {
      viewModel.updateMoney(200000);
      final reached = viewModel.hasReachedNisab(
        goldPricePerGram: 1000,
        silverPricePerGram: 1,
      );
      expect(reached, isTrue);
    });

    test('reset clears all fields', () {
      viewModel.updateMoney(100000);
      viewModel.updateGold(50);
      viewModel.updateSilver(200);
      viewModel.updateTrade(30000);
      viewModel.updateDebtsOwed(10000);
      viewModel.updateDebtsReceive(5000);
      viewModel.reset();

      expect(viewModel.money, 0);
      expect(viewModel.gold, 0);
      expect(viewModel.silver, 0);
      expect(viewModel.trade, 0);
      expect(viewModel.debtsOwed, 0);
      expect(viewModel.debtsReceive, 0);
    });

    test('notifyListeners fires on update', () {
      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.updateMoney(1000);
      expect(notified, isTrue);
    });
  });
}
