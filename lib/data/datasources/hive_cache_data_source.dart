import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/app_logger.dart';

class HiveCacheDataSource {
  static const String _boxName = 'zakat_cache';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    AppLogger.cache('initialized', _boxName);
  }

  Future<void> write(String key, dynamic value) async {
    await _box.put(key, value);
    AppLogger.cache('write', key);
  }

  dynamic read(String key) {
    final value = _box.get(key);
    AppLogger.cache('read', key, hit: value != null);
    return value;
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool hasKey(String key) => _box.containsKey(key);

  int get length => _box.length;

  List<String> get keys => _box.keys.cast<String>().toList();
}
