import 'package:web/web.dart' as web;

String getWindowOrigin() => web.window.location.origin;

void pushHistoryState(String title, String url) {
  web.window.history.pushState(null, title, url);
}
