// ================================================================
// core/utils/responsive_helper.dart — Responsive Design (بند 10)
// Small Phone · Phone · Tablet · Landscape
// ================================================================
import 'package:flutter/material.dart';

enum DeviceType { smallPhone, phone, largePhone, tablet }

class ResponsiveHelper {
  final BuildContext context;
  late final double width;
  late final double height;
  late final Orientation orientation;

  ResponsiveHelper(this.context) {
    final size = MediaQuery.sizeOf(context);
    width = size.width;
    height = size.height;
    orientation = MediaQuery.orientationOf(context);
  }

  static ResponsiveHelper of(BuildContext ctx) => ResponsiveHelper(ctx);

  bool get isLandscape => orientation == Orientation.landscape;
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600;
  bool get isSmall => width < 360;

  DeviceType get deviceType {
    if (width < 360) return DeviceType.smallPhone;
    if (width < 480) return DeviceType.phone;
    if (width < 600) return DeviceType.largePhone;
    return DeviceType.tablet;
  }

  // ── Adaptive spacing ─────────────────────────────────────────
  double get hp => isSmall
      ? 12
      : isTablet
          ? 24
          : 16; // horizontal padding
  double get vp => isSmall
      ? 8
      : isTablet
          ? 20
          : 12; // vertical padding

  // ── Font sizes ───────────────────────────────────────────────
  double get titleSize => isSmall
      ? 18
      : isTablet
          ? 26
          : 22;
  double get bodySize => isSmall
      ? 13
      : isTablet
          ? 17
          : 15;
  double get smallSize => isSmall
      ? 11
      : isTablet
          ? 14
          : 12;

  // ── Grid ────────────────────────────────────────────────────
  int get gridCols => isTablet ? (isLandscape ? 4 : 3) : 2;

  // ── Generic adapter ─────────────────────────────────────────
  T when<T>({required T phone, T? tablet, T? small}) {
    if (isSmall && small != null) return small;
    if (isTablet && tablet != null) return tablet;
    return phone;
  }
}

// ── Widget helper ────────────────────────────────────────────────
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ResponsiveHelper) builder;
  const ResponsiveBuilder({super.key, required this.builder});
  @override
  Widget build(BuildContext ctx) => builder(ctx, ResponsiveHelper(ctx));
}
