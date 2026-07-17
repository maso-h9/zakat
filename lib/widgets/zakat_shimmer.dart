// ================================================================
// widgets/zakat_shimmer.dart — Skeleton Loading (بند 11)
// ================================================================
import 'package:flutter/material.dart';

// ── Shimmer Base ─────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  const ShimmerBox(
      {super.key,
      required this.width,
      required this.height,
      this.borderRadius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E3A2A) : const Color(0xFFE8E3D5);
    final high = isDark ? const Color(0xFF2A5A3A) : const Color(0xFFF5F0E8);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: Color.lerp(base, high, _anim.value),
        ),
      ),
    );
  }
}

// ── Gold Banner Skeleton ──────────────────────────────────────────
class ShimmerGoldBanner extends StatelessWidget {
  const ShimmerGoldBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A2A1A) : const Color(0xFF0D4A2F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Text('🥇', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: 180, height: 12, borderRadius: 5),
          const SizedBox(height: 6),
          ShimmerBox(width: 120, height: 10, borderRadius: 5),
        ])),
        const SizedBox(width: 12),
        const ShimmerBox(width: 20, height: 20, borderRadius: 10),
      ]),
    );
  }
}

// ── Dashboard Card Skeleton ───────────────────────────────────────
class ShimmerDashboardCard extends StatelessWidget {
  const ShimmerDashboardCard({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ShimmerBox(width: 80, height: 10, borderRadius: 5),
        const SizedBox(height: 10),
        ShimmerBox(width: double.infinity, height: 18, borderRadius: 6),
        const SizedBox(height: 6),
        ShimmerBox(width: 60, height: 10, borderRadius: 5),
      ]),
    );
  }
}

// ── Dashboard Grid Skeleton ───────────────────────────────────────
class ShimmerDashboardGrid extends StatelessWidget {
  const ShimmerDashboardGrid({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Column(children: [
        Row(children: [
          const Expanded(child: ShimmerDashboardCard()),
          const SizedBox(width: 12),
          const Expanded(child: ShimmerDashboardCard()),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Expanded(child: ShimmerDashboardCard()),
          const SizedBox(width: 12),
          const Expanded(child: ShimmerDashboardCard()),
        ]),
      ]),
    );
  }
}

// ── List Item Skeleton ────────────────────────────────────────────
class ShimmerListItem extends StatelessWidget {
  final bool hasLeading;
  const ShimmerListItem({super.key, this.hasLeading = true});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        if (hasLeading) ...[
          ShimmerBox(width: 44, height: 44, borderRadius: 10),
          const SizedBox(width: 12),
        ],
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: double.infinity, height: 13, borderRadius: 5),
          const SizedBox(height: 6),
          ShimmerBox(width: 140, height: 10, borderRadius: 5),
        ])),
      ]),
    );
  }
}

// ── Hadith Card Skeleton ──────────────────────────────────────────
class ShimmerHadithCard extends StatelessWidget {
  const ShimmerHadithCard({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ShimmerBox(width: 100, height: 10, borderRadius: 5),
        const SizedBox(height: 12),
        ShimmerBox(width: double.infinity, height: 12, borderRadius: 5),
        const SizedBox(height: 6),
        ShimmerBox(width: double.infinity, height: 12, borderRadius: 5),
        const SizedBox(height: 6),
        ShimmerBox(width: 200, height: 12, borderRadius: 5),
        const SizedBox(height: 12),
        ShimmerBox(width: 150, height: 10, borderRadius: 5),
      ]),
    );
  }
}

// ── Settings Section Skeleton ─────────────────────────────────────
class ShimmerSettingsSection extends StatelessWidget {
  final int itemCount;
  const ShimmerSettingsSection({super.key, this.itemCount = 3});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final div = isDark ? const Color(0xFF1A3A2A) : const Color(0xFFEEE8D5);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Column(
        children: List.generate(
            itemCount,
            (i) => Column(children: [
                  const ShimmerListItem(),
                  if (i < itemCount - 1) Divider(height: 1, color: div),
                ])),
      ),
    );
  }
}

// ── Nisab Comparison Skeleton ─────────────────────────────────────
class ShimmerNisabCard extends StatelessWidget {
  const ShimmerNisabCard({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final div = isDark ? const Color(0xFF1A3A2A) : const Color(0xFFEEE8D5);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Row(children: [
        Expanded(
            child: Column(children: [
          ShimmerBox(width: 80, height: 10, borderRadius: 5),
          const SizedBox(height: 8),
          ShimmerBox(width: 100, height: 16, borderRadius: 6),
        ])),
        Container(width: 1, height: 40, color: div),
        Expanded(
            child: Column(children: [
          ShimmerBox(width: 80, height: 10, borderRadius: 5),
          const SizedBox(height: 8),
          ShimmerBox(width: 100, height: 16, borderRadius: 6),
        ])),
      ]),
    );
  }
}
