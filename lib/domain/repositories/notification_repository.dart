abstract class NotificationRepository {
  Future<void> init();
  Future<void> scheduleZakatReminder({
    required int year,
    required DateTime dueDate,
  });
  Future<void> scheduleRamadanReminder();
  Future<void> scheduleFitrReminder();
  Future<void> cancelAll();
}
