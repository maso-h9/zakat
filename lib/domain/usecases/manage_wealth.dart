import '../entities/wealth_data.dart';
import '../entities/zakat_record.dart';
import '../repositories/zakat_repository.dart';

class SaveWealthUseCase {
  final ZakatRepository _repo;

  SaveWealthUseCase(this._repo);

  Future<void> execute(WealthData wealth) => _repo.saveWealth(wealth);
}

class LoadWealthUseCase {
  final ZakatRepository _repo;

  LoadWealthUseCase(this._repo);

  Future<WealthData> execute() => _repo.loadWealth();
}

class SaveZakatHistoryUseCase {
  final ZakatRepository _repo;

  SaveZakatHistoryUseCase(this._repo);

  Future<void> execute(List<ZakatRecord> history) =>
      _repo.saveHistory(history);
}

class LoadZakatHistoryUseCase {
  final ZakatRepository _repo;

  LoadZakatHistoryUseCase(this._repo);

  Future<List<ZakatRecord>> execute() => _repo.loadHistory();
}

class AddZakatRecordUseCase {
  final ZakatRepository _repo;

  AddZakatRecordUseCase(this._repo);

  Future<ZakatRecord> execute({
    required int year,
    required double amount,
    required double wealth,
    required DateTime date,
    String note = '',
  }) async {
    final record = ZakatRecord(
      year: year,
      amount: amount,
      wealth: wealth,
      date: date,
      note: note,
    );
    final history = await _repo.loadHistory();
    history.add(record);
    await _repo.saveHistory(history);
    return record;
  }
}
