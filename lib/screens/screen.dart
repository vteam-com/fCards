import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cards/utils/font_scale_notifier.dart';
import 'package:cards/utils/scale_helper.dart';

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
class Screen extends StatefulWidget {
  /// Creates a Screen widget
  ///
  /// [title] - Text shown in app bar
  /// [child] - Main content widget
  /// [onRefresh] - Optional callback for refresh button
  /// [getLinkToShare] - Optional callback to get shareable link
  /// [rightText] - Optional text shown on right side of app bar
  /// [isWaiting] - Shows loading indicator when true
  const Screen({
    super.key,
    required this.title,
    required this.child,
    this.onRefresh,
    this.getLinkToShare,
    this.rightText = '',
    required this.isWaiting,
  });

  /// Title text shown in the app bar
  final String title;

  /// Main content widget displayed in the body
  final Widget child;

  /// Optional callback function triggered when refresh button is pressed
  final Function? onRefresh;

  /// Optional callback that returns a string URL/link for sharing
  final String Function()? getLinkToShare;

  /// Optional text shown on right side of app bar (e.g. user name)
  final String rightText;

  /// When true, displays a loading indicator instead of the main content
  final bool isWaiting;

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  String _version = '';
  late final FontScaleNotifier _fontScaleNotifier;

  @override
  void initState() {
    super.initState();
    _fontScaleNotifier = FontScaleNotifier();
    _fontScaleNotifier.initialize();
    _getAppVersion();
  }

  /// Fetches the application version from the platform package info.
  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      debugPrint('Error getting package info: $e');
      if (mounted) {
        setState(() {
          _version = '1.0.0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.yellow.shade100.withAlpha(200)),
          ),
        ),
        actions: [
          ///
          /// FONT SCALE TOGGLE
          ///
          AnimatedBuilder(
            animation: _fontScaleNotifier,
            builder: (context, child) {
              return IconButton(
                icon: Icon(_fontScaleNotifier.currentIcon),
                tooltip: 'Font size: ${_fontScaleNotifier.currentLabel}',
                onPressed: () async {
                  await _fontScaleNotifier.toggleFontScale();
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Font size: ${_fontScaleNotifier.currentLabel}',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),

          ///
          /// VERSION & LICENSES
          ///
          TextButton(
            child: Text(_version),
            onPressed: () async {
              if (context.mounted) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        LicensePage(
                          applicationName: 'VTeam Cards',
                          applicationVersion: _version,
                        ),
                  ),
                );
              }
            },
          ),

          ///
          /// REFRESH
          ///
          if (widget.onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => widget.onRefresh!(),
            ),

          /// RIGHT SIDE TEXT (User Name)
          if (widget.rightText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.rightText,
                style: TextStyle(color: Colors.yellow.shade100.withAlpha(200)),
              ),
            ),

          //
          // Share link
          //
          if (widget.getLinkToShare != null)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(text: widget.getLinkToShare!()),
                );
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
                fit: BoxFit.cover,
              ),
            ),
            child: SizedBox.expand(
              child: DefaultTextStyle(
                style: ScaleHelper.getScaledTextStyle(
                  color: Colors.green.shade100,
                  fontSize: 20,
                ),
                child: widget.isWaiting ? _displayWaiting() : widget.child,
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
      width: ScaleHelper.scaleDimension(400),
      height: ScaleHelper.scaleDimension(400),
      child: Center(
        child: CupertinoActivityIndicator(
          radius: ScaleHelper.scaleDimension(40),
        ),
      ),
    );
  }
}
