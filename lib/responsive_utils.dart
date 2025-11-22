import 'package:flutter/material.dart';

/// Responsive utility class for adaptive layouts
class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  // Screen dimensions
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // Breakpoints
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 1024;

  // Device type detection
  bool get isMobile => screenWidth < mobileBreakpoint;
  bool get isTablet => screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;
  bool get isDesktop => screenWidth >= tabletBreakpoint;

  // Responsive padding
  double get horizontalPadding {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }

  double get verticalPadding {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 20;
  }

  // Responsive font sizes
  double responsiveFontSize(double mobileSize, {double? tabletSize, double? desktopSize}) {
    if (isMobile) return mobileSize;
    if (isTablet) return tabletSize ?? (mobileSize * 1.2);
    return desktopSize ?? (mobileSize * 1.4);
  }

  // Grid cross axis count
  int getGridCrossAxisCount({int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  // Max width for centered content
  double get maxContentWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return 700;
    return 900;
  }

  // Form max width
  double get maxFormWidth {
    if (isMobile) return screenWidth;
    return 500;
  }

  // Responsive spacing
  double spacing(double baseSize) {
    if (isMobile) return baseSize;
    if (isTablet) return baseSize * 1.3;
    return baseSize * 1.5;
  }

  // Avatar radius
  double get avatarRadius {
    if (isMobile) return 28;
    if (isTablet) return 35;
    return 40;
  }

  // Profile avatar radius
  double get profileAvatarRadius {
    if (isMobile) return 30;
    if (isTablet) return 40;
    return 50;
  }

  // Button height
  double get buttonHeight {
    if (isMobile) return 50;
    if (isTablet) return 55;
    return 60;
  }

  // Search bar height
  double get searchBarHeight {
    if (isMobile) return 45;
    if (isTablet) return 50;
    return 55;
  }

  // Card elevation
  double get cardElevation {
    if (isMobile) return 4;
    if (isTablet) return 6;
    return 8;
  }
}

/// Extension for easy access
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
