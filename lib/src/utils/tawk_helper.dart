import 'package:flutter/foundation.dart';
import 'tawk_stub.dart' if (dart.library.js) 'tawk_web.dart' as tawk;

class TawkHelper {
  static void show() {
    if (kIsWeb) {
      tawk.showTawkWidget();
    }
  }

  static void hide() {
    if (kIsWeb) {
      tawk.hideTawkWidget();
    }
  }
}
