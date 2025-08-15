import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Defines breakpoint constants for responsive design
class ResponsiveBreakpoints {
  /// Maximum width for phone layout
  static const double phone = 600;

  /// Maximum width for tablet layout
  static const double tablet = 900;

  /// Minimum width for desktop layout
  static const double desktop = 1200;
}

/// Extension on BuildContext to easily check device type based on screen width
extension DeviceType on BuildContext {
  /// Returns true if screen width is less than phone breakpoint
  bool get isPhone =>
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.phone;

  /// Returns true if screen width is between phone and tablet breakpoints
  bool get isTablet =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.phone &&
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.tablet;

  /// Returns true if screen width is greater than desktop breakpoint
  bool get isDesktop =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.desktop;
}

/// A scaffold widget that provides a common screen layout with app bar and background
class Screen extends StatelessWidget {
  /// Creates a Screen widget
  ///
  /// [title] - Text shown in app bar
  /// [version] - Version number shown in app bar
  /// [child] - Main content widget
  /// [onRefresh] - Optional callback for refresh button
  /// [getLinkToShare] - Optional callback to get shareable link
  /// [rightText] - Optional text shown on right side of app bar
  /// [isWaiting] - Shows loading indicator when true
  const Screen({
    super.key,
    required this.title,
    required this.version,
    required this.child,
    this.onRefresh,
    this.getLinkToShare,
    this.rightText = '',
    required this.isWaiting,
  });

  /// Title text shown in the app bar
  final String title;

  /// Version number shown in app bar that links to licenses page
  final String version;

  /// Optional text shown on right side of app bar (e.g. user name)
  final String rightText;

  /// Main content widget displayed in the body
  final Widget child;

  /// Optional callback function triggered when refresh button is pressed
  final Function? onRefresh;

  /// Optional callback that returns a string URL/link for sharing
  final String Function()? getLinkToShare;

  /// When true, displays a loading indicator instead of the main content
  final bool isWaiting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: TextStyle(color: Colors.yellow.shade100.withAlpha(200)),
          ),
        ),
        actions: [
          ///
          /// VERSION & LICENSES
          ///
          TextButton(
            child: Text(version),
            onPressed: () async {
              if (context.mounted) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        LicensePage(
                      applicationName: 'VTeam Cards',
                      applicationVersion: version,
                    ),
                  ),
                );
              }
            },
          ),

          ///
          /// REFRESH
          ///
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                onRefresh!();
              },
            ),

          /// RIGHT SIDE TEXT (User Name)
          if (rightText.isNotEmpty)
            Padding(
              // Add padding to prevent text from being cut off
              padding: EdgeInsets.only(right: 8.0), // Adjust as needed
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  rightText,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          //
          // Share link
          //
          if (getLinkToShare != null)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                SharePlus.instance.share(ShareParams(text: getLinkToShare!()));
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/table_top.png'),
                fit: BoxFit.cover, // adjust the fit as needed
              ),
            ),
            child: SizedBox.expand(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: Colors.green.shade100,
                  fontSize: 20,
                ), // Your default style
                child: isWaiting ? _displayWaiting() : child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayWaiting() {
    /// Builds a loading indicator widget
    return SizedBox(
      width: 400,
      height: 400,
      child: Center(
        child: const CupertinoActivityIndicator(
          radius: 40,
        ),
      ),
    );
  }
}
