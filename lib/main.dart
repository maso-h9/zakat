import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/zakat_provider.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/crashlytics_service.dart';
import 'services/remote_config_service.dart';
import 'services/fcm_service.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/dependency_provider.dart';
import 'core/di/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: ZakatTheme.deepGreen,
    statusBarIconBrightness: Brightness.light,
  ));
  unawaited(SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]));

  // Firebase — blocking init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize service locator
  await di.initServiceLocator();

  // Launch app
  runApp(const ZakatApp());

  // Heavy services after first frame
  unawaited(_initServicesInBackground());
}

// تهيئة الخدمات الثقيلة في الخلفية بعد فتح التطبيق
Future<void> _initServicesInBackground() async {
  // انتظر حتى يستقر الـ UI (أقل وقت ممكن)
  await Future.delayed(const Duration(milliseconds: 300));
  try {
    await CrashlyticsService.init();
  } catch (_) {}
  try {
    await RemoteConfigService.init().timeout(
      const Duration(seconds: 5),
    );
  } catch (_) {}
  try {
    await FcmService.init();
  } catch (_) {}
  try {
    await NotificationService().init();
  } catch (_) {}
}

class ZakatApp extends StatelessWidget {
  const ZakatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZakatProvider()..init()),
        ...DependencyProvider.providers,
      ],
      child: Selector<ZakatProvider, ({bool isDark, bool isRamadan, Locale locale})>(
        selector: (_, p) => (isDark: p.isDarkMode, isRamadan: p.isRamadanMode, locale: p.locale),
        builder: (_, data, __) => MaterialApp(
          title: 'Zakat',
          debugShowCheckedModeBanner: false,
          theme: data.isRamadan ? ZakatTheme.ramadanTheme : ZakatTheme.theme,
          darkTheme: data.isRamadan ? ZakatTheme.darkRamadanTheme : ZakatTheme.darkTheme,
          themeMode: data.isDark ? ThemeMode.dark : ThemeMode.light,
          locale: data.locale,
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

// SplashScreen — بدون تعديل
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (_, a, __, child) =>
                  FadeTransition(opacity: a, child: child),
            ));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ZakatTheme.mainGradient),
        child: Stack(children: [
          Positioned(
              top: -80,
              right: -80,
              child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04)))),
          Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZakatTheme.gold.withValues(alpha: 0.08)))),
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: ZakatTheme.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: ZakatTheme.gold, width: 2),
                      ),
                      child: const Icon(Icons.volunteer_activism,
                          color: ZakatTheme.gold, size: 50),
                    ),
                    const SizedBox(height: 24),
                    const Text('الزكاة',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Scheherazade')),
                    const SizedBox(height: 6),
                    const Text('دليلك الشامل لأداء فريضة الزكاة',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Scheherazade')),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: ZakatTheme.gold.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        '﴿وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ﴾',
                        style: TextStyle(
                            color: ZakatTheme.gold,
                            fontSize: 18,
                            fontFamily: 'Scheherazade',
                            height: 1.8),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
