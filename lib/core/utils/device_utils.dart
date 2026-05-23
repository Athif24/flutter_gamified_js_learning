import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

String detectDeviceType() {
  if (kIsWeb) return 'web';
  if (Platform.isAndroid || Platform.isIOS) return 'mobile';
  return 'desktop';
}
