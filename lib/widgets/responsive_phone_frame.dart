import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/greenleaf_theme.dart';

class ResponsivePhoneFrame extends StatelessWidget {
  const ResponsivePhoneFrame({super.key, required this.child});

  final Widget child;

  static const double phoneWidth = 390;
  static const double phoneHeight = 844;
  static const double topSafePadding = 44;
  static const double bottomSafePadding = 18;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final bool isRealPhone = (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android) &&
        size.shortestSide < 600;
    final bool showPhoneFrame = !isRealPhone && size.width >= 540;

    if (!showPhoneFrame) {
      return ScaffoldMessenger(child: child);
    }

    return ColoredBox(
      color: GreenleafColors.frameBackdrop,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _PhoneChassis(
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  size: const Size(phoneWidth, phoneHeight),
                  padding: const EdgeInsets.only(
                    top: topSafePadding,
                    bottom: bottomSafePadding,
                  ),
                  viewPadding: const EdgeInsets.only(
                    top: topSafePadding,
                    bottom: bottomSafePadding,
                  ),
                  viewInsets: EdgeInsets.zero,
                ),
                child: ScaffoldMessenger(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneChassis extends StatelessWidget {
  const _PhoneChassis({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E1C),
        borderRadius: BorderRadius.circular(54),
        border: Border.all(
          color: const Color(0xFF39403C),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 42,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42),
        child: SizedBox(
          width: ResponsivePhoneFrame.phoneWidth,
          height: ResponsivePhoneFrame.phoneHeight,
          child: Stack(
            children: [
              Positioned.fill(child: child),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: _PhoneStatusBarAndNotch(),
                ),
              ),
              Positioned(
                bottom: 7,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 128,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4D2B).withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneStatusBarAndNotch extends StatelessWidget {
  const _PhoneStatusBarAndNotch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Top notch
          Container(
            width: 150,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1E1C),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333835),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF28333D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF424B47),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status indicators left and right of notch
          const Padding(
            padding: EdgeInsets.fromLTRB(26, 10, 22, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: GreenleafColors.forestGreen,
                    decoration: TextDecoration.none,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.signal_cellular_4_bar_rounded,
                      size: 14,
                      color: GreenleafColors.forestGreen,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.wifi_rounded,
                      size: 14,
                      color: GreenleafColors.forestGreen,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.battery_full_rounded,
                      size: 15,
                      color: GreenleafColors.forestGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
