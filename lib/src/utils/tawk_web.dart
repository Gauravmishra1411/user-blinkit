// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void showTawkWidget() {
  js.context.callMethod('eval', [
    'if(typeof Tawk_API !== "undefined" && typeof Tawk_API.showWidget === "function") Tawk_API.showWidget();'
  ]);
}

void hideTawkWidget() {
  js.context.callMethod('eval', [
    'if(typeof Tawk_API !== "undefined" && typeof Tawk_API.hideWidget === "function") Tawk_API.hideWidget();'
  ]);
}
