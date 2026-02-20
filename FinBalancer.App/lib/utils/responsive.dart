import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Breakpoint za prelazak na "široki" layout (web desktop).
const double kWebBreakpoint = 700;

/// Maksimalna širina sadržaja na webu da ne bude previše raširen.
const double kWebMaxContentWidth = 800;

/// Je li trenutno široki ekran (web desktop) – koristi NavigationRail umjesto bottom nav.
bool isWideScreen(BuildContext context) {
  if (!kIsWeb) return false;
  return MediaQuery.sizeOf(context).width >= kWebBreakpoint;
}

/// Wrapper koji na webu ograničava širinu i centrira sadržaj.
Widget webAdaptiveContent(BuildContext context, Widget child) {
  if (!kIsWeb) return child;
  final width = MediaQuery.sizeOf(context).width;
  if (width < kWebBreakpoint) return child;
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kWebMaxContentWidth),
      child: child,
    ),
  );
}
