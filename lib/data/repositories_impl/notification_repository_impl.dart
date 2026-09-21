import '../../domain/repositories/notification_repository.dart';
import '../../services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _service;

  NotificationRepositoryImpl(this._service);

  @override
  Future<void> init() => _service.init();

  @override
  Future<void> scheduleZakatReminder({
    required int year,
    required DateTime dueDate,
  }) =>
      _service.scheduleZakatAnnual(nisabDate: dueDate);

  @override
  Future<void> scheduleRamadanReminder() =>
      _service.scheduleRamadanDailyReminder();

  @override
  Future<void> scheduleFitrReminder() =>
      _service.scheduleFitrReminder(eidDate: DateTime.now());

  @override
  Future<void> cancelAll() => _service.cancelAll();
}
