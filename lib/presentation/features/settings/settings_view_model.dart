import 'package:flutter/material.dart';
import '../../../domain/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repo;

  SettingsViewModel(this._repo);

  bool _isDarkMode = false;
  String _language = 'ar';
  bool _cloudSyncEnabled = false;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get cloudSyncEnabled => _cloudSyncEnabled;

  Future<void> loadSettings() async {
    _isDarkMode = await _repo.loadDarkMode();
    _language = await _repo.loadLanguage();
    _cloudSyncEnabled = await _repo.loadCloudSync();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool on) async {
    _isDarkMode = on;
    notifyListeners();
    await _repo.saveDarkMode(on);
  }

  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    notifyListeners();
    await _repo.saveLanguage(langCode);
  }

  Future<void> toggleCloudSync(bool on) async {
    _cloudSyncEnabled = on;
    notifyListeners();
    await _repo.saveCloudSync(on);
  }
}
