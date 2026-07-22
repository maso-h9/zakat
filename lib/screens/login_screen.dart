// ================================================================
// login_screen.dart — شاشة تسجيل الدخول (مُصحَّحة)
// lib/screens/login_screen.dart
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isRegister = false;
  bool _obscure = true;

  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  String? _verificationId;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 15)),
      backgroundColor: isError ? ZakatTheme.error : ZakatTheme.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _handleEmailAuth() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showMsg(AppLocalizations.of(context).fillAllFields);
      return;
    }
    setState(() => _loading = true);

    AuthResult result;
    if (_isRegister) {
      result = await AuthService.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
    } else {
      result = await AuthService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
    }

    setState(() => _loading = false);
    if (result.isSuccess) {
      if (mounted) Navigator.pop(context);
    } else {
      _showMsg(result.error!);
    }
  }

  Future<void> _handleGoogle() async {
    setState(() => _loading = true);
    final result = await AuthService.signInWithGoogle();
    setState(() => _loading = false);
    if (result.isSuccess) {
      if (mounted) Navigator.pop(context);
    } else {
      _showMsg(result.error!);
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showMsg(AppLocalizations.of(context).enterPhoneNumber);
      return;
    }
    setState(() => _loading = true);

    await AuthService.sendPhoneOtp(
      phoneNumber: phone,
      onVerified: (PhoneAuthCredential cred) async {
        // تحقق تلقائي (Android فقط)
        final result = await AuthService.signInWithCredential(cred);
        setState(() => _loading = false);
        if (result.isSuccess && mounted) {
          Navigator.pop(context);
        } else if (!result.isSuccess) {
          _showMsg(result.error!);
        }
      },
      onFailed: (FirebaseAuthException e) {
        setState(() => _loading = false);
        _showMsg(AuthService.arabicError(e.code));
      },
      onCodeSent: (String vId, int? resendToken) {
        setState(() {
          _verificationId = vId;
          _otpSent = true;
          _loading = false;
        });
        _showMsg(AppLocalizations.of(context).otpSent, isError: false);
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null || _otpCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    final result = await AuthService.verifyPhoneOtp(
      verificationId: _verificationId!,
      otp: _otpCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (result.isSuccess) {
      if (mounted) Navigator.pop(context);
    } else {
      _showMsg(result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = p.isDarkMode;
    final bg = ZakatTheme.scaffoldBgAdaptive(isDark);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor:
              isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen,
          title: Text(
            _isRegister ? l10n.createNewAccount : l10n.loginTitle,
            style: const TextStyle(fontFamily: 'Scheherazade'),
          ),
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: ZakatTheme.gold,
            labelColor: ZakatTheme.gold,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
                fontFamily: 'Scheherazade', fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: AppLocalizations.of(context).loginWithEmail),
              const Tab(text: 'Google'),
              Tab(text: l10n.loginWithPhone),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildEmailTab(cardColor, textColor, isDark),
            _buildGoogleTab(cardColor, textColor, isDark),
            _buildPhoneTab(cardColor, textColor, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTab(Color cardColor, Color textColor, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
              gradient: ZakatTheme.mainGradient, shape: BoxShape.circle),
          child: const Icon(Icons.volunteer_activism,
              color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          _isRegister ? l10n.createNewAccount : l10n.welcomeBack,
          style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
          ),
          child: Column(children: [
            if (_isRegister) ...[
              _field(_nameCtrl, l10n.userLabel, Icons.person_outline,
                  isDark: isDark),
              const SizedBox(height: 14),
            ],
            _field(_emailCtrl, l10n.email, Icons.email_outlined,
                type: TextInputType.emailAddress, isDark: isDark),
            const SizedBox(height: 14),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'Scheherazade', color: textColor),
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon:
                      Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleEmailAuth,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_isRegister ? l10n.createAccountButton : l10n.loginButton,
                        style: const TextStyle(
                            fontFamily: 'Scheherazade', fontSize: 17)),
              ),
            ),
            if (!_isRegister)
              TextButton(
                onPressed: () async {
                  if (_emailCtrl.text.trim().isEmpty) {
                    _showMsg(l10n.enterEmailFirst);
                    return;
                  }
                  final r =
                      await AuthService.resetPassword(_emailCtrl.text.trim());
                  _showMsg(r.message ?? r.error!, isError: !r.isSuccess);
                },
                child: Text(l10n.forgotPassword,
                    style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        color: ZakatTheme.deepGreen)),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _isRegister = !_isRegister),
          child: Text(
            _isRegister
                ? l10n.loginTitle
                : l10n.createNewAccount,
            style: const TextStyle(
                fontFamily: 'Scheherazade',
                color: ZakatTheme.deepGreen,
                fontSize: 15),
          ),
        ),
      ]),
    );
  }

  Widget _buildGoogleTab(Color cardColor, Color textColor, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
          ),
          child: Column(children: [
            const Text('🔐', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(l10n.loginWithGoogle,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            /* const Text(
              '⚠️ يحتاج إضافة SHA-1 في Firebase Console\nراجع CHANGES_V4.md للتفاصيل',
              style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 12,
                  color: ZakatTheme.lightText,
                  height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),*/
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _handleGoogle,
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: ZakatTheme.deepGreen.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('G',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                label: Text(l10n.continueWithGoogle,
                    style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 16)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPhoneTab(Color cardColor, Color textColor, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
          ),
          child: Column(children: [
            const Text('📱', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(l10n.loginWithPhone,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            const SizedBox(height: 6),
            Text(
              l10n.phoneAuthWarning,
              style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 12,
                  color: ZakatTheme.lightText,
                  height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _field(
              _phoneCtrl,
              l10n.phoneHint,
              Icons.phone_outlined,
              type: TextInputType.phone,
              enabled: !_otpSent,
              isDark: isDark,
            ),
            if (_otpSent) ...[
              const SizedBox(height: 14),
              _field(_otpCtrl, l10n.otpHint, Icons.sms_outlined,
                  type: TextInputType.number, isDark: isDark),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_otpSent ? l10n.verifyCode : l10n.sendCode,
                        style: const TextStyle(
                            fontFamily: 'Scheherazade', fontSize: 17)),
              ),
            ),
            if (_otpSent)
              TextButton(
                onPressed: () => setState(() {
                  _otpSent = false;
                  _otpCtrl.clear();
                }),
                child: Text(l10n.changePhone,
                    style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        color: ZakatTheme.deepGreen)),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool enabled = true,
    required bool isDark,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      textDirection: TextDirection.rtl,
      enabled: enabled,
      style: TextStyle(
          fontFamily: 'Scheherazade',
          color: isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
