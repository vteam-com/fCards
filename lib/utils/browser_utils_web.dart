import 'package:web/web.dart' as web;

String getWindowOrigin() => web.window.location.origin;

void pushHistoryState(String title, String url) {
  web.window.history.pushState(null, title, url);
}

Future<void> toggleFullscreen() async {
  if (web.document.fullscreenElement == null) {
    web.document.documentElement?.requestFullscreen();
  } else {
    web.document.exitFullscreen();
  }
}
