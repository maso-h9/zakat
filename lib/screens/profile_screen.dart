// ================================================================
// profile_screen.dart — شاشة الحساب الشخصي
// lib/screens/profile_screen.dart
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final user = AuthService.currentUser;

    if (user == null) {
      return _buildNotSignedIn(context, isDark);
    }
    return _buildProfile(context, p, isDark, user);
  }

  // ─── غير مسجّل ───────────────────────────────────────────────
  Widget _buildNotSignedIn(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final bg = ZakatTheme.scaffoldBgAdaptive(isDark);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(l10n.profileTitle,
              style: const TextStyle(fontFamily: 'Scheherazade')),
          backgroundColor:
              isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
                ),
                child: Column(children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      gradient: ZakatTheme.mainGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 45),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.loginToSave,
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.loginToSaveDesc,
                    style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: 14,
                        color: isDark
                            ? ZakatTheme.darkTextSecondary
                            : ZakatTheme.medText,
                        height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      icon: const Icon(Icons.login),
                      label: Text(l10n.loginButton,
                          style: const TextStyle(
                              fontFamily: 'Scheherazade', fontSize: 17)),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── مسجّل دخول ──────────────────────────────────────────────
  Widget _buildProfile(
      BuildContext context, ZakatProvider p, bool isDark, dynamic user) {
    final l10n = AppLocalizations.of(context);
    final bg = ZakatTheme.scaffoldBgAdaptive(isDark);
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    final displayName = user.displayName ?? l10n.userLabel;
    final email = user.email ?? user.phoneNumber ?? '';
    final photoUrl = user.photoURL;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(l10n.profileTitle,
              style: const TextStyle(fontFamily: 'Scheherazade')),
          backgroundColor:
              isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // بطاقة المستخدم
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: ZakatTheme.mainGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: ZakatTheme.gold.withValues(alpha: 0.3),
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'م',
                          style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Scheherazade',
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        if (email.isNotEmpty)
                          Text(email,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Scheherazade',
                                  fontSize: 13)),
                      ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // إحصائيات الحساب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.accountSummary,
                      style: TextStyle(
                          fontFamily: 'Scheherazade',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 14),
                  _statRow(
                      l10n.totalZakatPaid,
                      '${p.totalZakatPaid.toStringAsFixed(0)} ${p.currencySymbol}',
                      Icons.volunteer_activism,
                      ZakatTheme.deepGreen,
                      isDark),
                  _statRow(l10n.yearsOfCompliance, '${p.yearsCount} سنة',
                      Icons.calendar_today, const Color(0xFF1565C0), isDark),
                  _statRow(
                      l10n.cloudSyncLabel,
                      p.cloudSyncEnabled ? l10n.cloudSyncEnabled : l10n.cloudSyncDisabled,
                      Icons.cloud_outlined,
                      ZakatTheme.gold,
                      isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // خيارات
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              ),
              child: Column(children: [
                _optionTile(
                  icon: Icons.sync,
                  title: l10n.syncDataNow,
                  subtitle: p.lastSyncTime != null
                      ? '${l10n.lastSync}: ${_formatTime(p.lastSyncTime!)}'
                      : l10n.neverSynced,
                  color: ZakatTheme.deepGreen,
                  isDark: isDark,
                  onTap: () => p.syncNow(),
                ),
                Divider(
                    height: 1,
                    color: isDark
                        ? ZakatTheme.darkBorder
                        : const Color(0xFFEEE8D5)),
                _optionTile(
                  icon: Icons.logout,
                  title: l10n.logoutButton,
                  subtitle: l10n.logoutDesc,
                  color: ZakatTheme.error,
                  isDark: isDark,
                  onTap: () => _confirmSignOut(context),
                ),
                Divider(
                    height: 1,
                    color: isDark
                        ? ZakatTheme.darkBorder
                        : const Color(0xFFEEE8D5)),
                _optionTile(
                  icon: Icons.delete_forever,
                  title: l10n.deleteAccount,
                  subtitle: l10n.deleteAccountDesc,
                  color: ZakatTheme.error,
                  isDark: isDark,
                  onTap: () => _confirmDelete(context),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statRow(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 14,
                    color: isDark
                        ? ZakatTheme.darkTextSecondary
                        : ZakatTheme.medText))),
        Text(value,
            style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
      ]),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 12,
              color: isDark
                  ? ZakatTheme.darkTextSecondary
                  : ZakatTheme.lightText)),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _confirmSignOut(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(l10n.logoutConfirm,
              style: const TextStyle(fontFamily: 'Scheherazade')),
          content: Text(l10n.logoutConfirmMessage,
              style: const TextStyle(fontFamily: 'Scheherazade')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel,
                    style: const TextStyle(fontFamily: 'Scheherazade'))),
            ElevatedButton(
              onPressed: () async {
                await AuthService.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: ZakatTheme.error),
              child: Text(l10n.signOutAction,
                  style: const TextStyle(fontFamily: 'Scheherazade')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(l10n.deleteAccountConfirm,
              style: const TextStyle(
                  fontFamily: 'Scheherazade', color: ZakatTheme.error)),
          content: Text(
              '${l10n.deleteAccountMessage}.',
              style: const TextStyle(fontFamily: 'Scheherazade', height: 1.7)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel,
                    style: const TextStyle(fontFamily: 'Scheherazade'))),
            ElevatedButton(
              onPressed: () async {
                final result = await AuthService.deleteAccount();
                if (context.mounted) {
                  Navigator.pop(context);
                  if (result.isSuccess) Navigator.pop(context);
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: ZakatTheme.error),
              child: Text(l10n.permanentDelete,
                  style: const TextStyle(fontFamily: 'Scheherazade')),
            ),
          ],
        ),
      ),
    );
  }
}
