import 'package:web/web.dart' as web;

/// Returns the current browser window origin.
String getWindowOrigin() => web.window.location.origin;

/// Pushes a new browser history entry without reloading the page.
void pushHistoryState(String title, String url) {
  web.window.history.pushState(null, title, url);
}
