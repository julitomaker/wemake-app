import 'package:flutter/foundation.dart';

/// Platform detection utilities that work on all platforms including web
class PlatformUtils {
  /// Returns true if running on a mobile device (iOS or Android)
  static bool get isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
           defaultTargetPlatform == TargetPlatform.android;
  }

  /// Returns true if running on a desktop platform
  static bool get isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Returns true if running on web
  static bool get isWeb => kIsWeb;

  /// Returns true if running on macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Returns true if running on iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Returns true if running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  /// Returns true if camera is available on this platform
  static bool get hasCameraSupport => isMobile;

  /// Returns true if image picker from gallery is available
  static bool get hasGallerySupport => isMobile || isMacOS;

  /// Returns true if local notifications are fully supported
  static bool get hasFullNotificationSupport => isMobile;

  /// Returns true if geolocation is supported
  static bool get hasGeolocationSupport => isMobile;

  /// Returns true if health data is available
  static bool get hasHealthDataSupport => isMobile;
}
