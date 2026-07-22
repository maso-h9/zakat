import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../core/di/service_locator.dart' as di;
import '../presentation/features/ai_chat/ai_chat_view_model.dart';
import '../presentation/features/calculator/calculator_view_model.dart';
import '../presentation/features/settings/settings_view_model.dart';
import '../presentation/features/home/home_view_model.dart';

/// Provider-based DI for screens that use MultiProvider.
/// The actual dependency graph lives in [di.sl] (get_it).
/// This bridges get_it singletons into Provider's tree.
class DependencyProvider {
  static List<SingleChildWidget> get providers {
    return [
      ChangeNotifierProvider(create: (_) => di.sl<AiChatViewModel>()),
      ChangeNotifierProvider(create: (_) => di.sl<CalculatorViewModel>()),
      ChangeNotifierProvider(
        create: (_) => di.sl<SettingsViewModel>()..loadSettings(),
      ),
      ChangeNotifierProvider(create: (_) => di.sl<HomeViewModel>()),
    ];
  }
}
