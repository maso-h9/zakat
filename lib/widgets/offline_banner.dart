// ================================================================
// widgets/offline_banner.dart — شريط حالة الاتصال (بند 15)
// يظهر تلقائياً عند انقطاع الإنترنت ويختفي عند عودته
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../models/zakat_provider.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService(),
      builder: (context, _) {
        final conn = ConnectivityService();
        final p = context.read<ZakatProvider>();
        final isDark = p.isDarkMode;

        if (conn.isOnline) return const SizedBox.shrink();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? const Color(0xFF2A1A00) : const Color(0xFFFFF3CD),
          child: Row(children: [
            const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                conn.statusText(p.isArabic),
                style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
            if (conn.offlineSince(p.isArabic) != null)
              Text(
                conn.offlineSince(p.isArabic)!,
                style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 11,
                  color: Colors.orange.withOpacity(0.7),
                ),
              ),
          ]),
        );
      },
    );
  }
}

// ── استخدام في home_screen (أضفه بعد AppBar) ─────────────────────
//
// Column(children: [
//   const OfflineBanner(),   // ← أضف هذا
//   Expanded(child: _buildBody(...)),
// ])
