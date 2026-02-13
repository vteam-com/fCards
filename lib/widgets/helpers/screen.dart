import 'dart:math' as math;

import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/app/constants_animation.dart';
import 'package:cards/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Defines breakpoint constants for responsive design
class ResponsiveBreakpoints {
  /// Maximum width for phone layout
  static const double phone = ConstLayout.breakpointPhone;

  /// Maximum width for tablet layout
  static const double tablet = ConstLayout.breakpointTablet;

  /// Minimum width for desktop layout
  static const double desktop = ConstLayout.breakpointDesktop;
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

  /// Main content widget displayed in the body
  final Widget child;

  /// Optional callback that returns a string URL/link for sharing
  final String Function()? getLinkToShare;

  /// When true, displays a loading indicator instead of the main content
  final bool isWaiting;

  /// Optional callback function triggered when refresh button is pressed
  final Function? onRefresh;

  /// Optional text shown on right side of app bar (e.g. user name)
  final String rightText;

  /// Title text shown in the app bar
  final String title;

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _ambientAnimationController;

  String _version = '';

  @override
  void initState() {
    super.initState();
    _ambientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: ConstAnimation.tableTopAmbientDuration,
      ),
    )..repeat();
    _getAppVersion();
  }

  @override
  void dispose() {
    _ambientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.title,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        actions: [
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
                    pageBuilder:
                        (
                          BuildContext _,
                          Animation<double> _,
                          Animation<double> _,
                        ) => LicensePage(
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

          /// USER AVATAR
          if (Firebase.apps.isNotEmpty &&
              FirebaseAuth.instance.currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ConstLayout.sizeS,
              ),
              child: _buildAvatar(FirebaseAuth.instance.currentUser!),
            ),

          /// RIGHT SIDE TEXT (User Name)
          if (widget.rightText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(ConstLayout.sizeS),
              child: Text(
                widget.rightText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
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
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/table_top.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(child: _buildTableTopAmbientOverlay()),
          SizedBox.expand(
            child: widget.isWaiting ? _displayWaiting() : widget.child,
          ),
        ],
      ),
    );
  }

  /// Builds one animated radial glow element for the tabletop ambiance.
  Widget _buildAmbientCircle({
    required Alignment alignment,
    required double diameter,
  }) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withAlpha(
                  ConstAnimation.tableTopAmbientCircleAlpha,
                ),
                Colors.white.withAlpha(
                  ConstAnimation.tableTopAmbientCircleAlpha,
                ),
                Colors.transparent,
                Colors.transparent,
              ],
              center: Alignment.center,
              radius: ConstAnimation.tableTopAmbientCircleRadius,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an avatar for authenticated users with guest and fallback handling.
  Widget _buildAvatar(User user) {
    if (user.isAnonymous) {
      return CircleAvatar(
        radius: ConstLayout.radiusXL,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        child: const Icon(Icons.person_outline),
      );
    }

    final photoUrl = user.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: ConstLayout.radiusXL,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: Theme.of(context).colorScheme.surface,
      );
    }

    final fallbackText = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : (user.email ?? 'U');

    return CircleAvatar(
      radius: ConstLayout.radiusXL,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: Text(fallbackText.characters.first.toUpperCase()),
    );
  }

  /// Builds the moving ambient light overlay shown over the tabletop texture.
  Widget _buildTableTopAmbientOverlay() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientAnimationController,
        builder: (BuildContext _, Widget? _) {
          final double progress = _ambientAnimationController.value;
          final double shortestSide = MediaQuery.sizeOf(context).shortestSide;
          final double circleSizeHuge =
              shortestSide * (ConstLayout.sizeL / ConstLayout.sizeM);

          return Stack(
            children: [
              _buildAmbientCircle(
                alignment: _orbitAlignment(
                  progress: progress,
                  phaseX: ConstLayout.sizeS / ConstLayout.sizeM,
                  phaseY: ConstLayout.sizeXS / ConstLayout.sizeS,
                  amplitudeX: ConstLayout.scaleSmall,
                  amplitudeY: ConstLayout.scaleTiny,
                ),
                diameter:
                    circleSizeHuge /
                    ConstAnimation.tableTopPrimaryCircleDivisor,
              ),
              _buildAmbientCircle(
                alignment: _orbitAlignment(
                  progress: progress,
                  phaseX:
                      (ConstLayout.sizeS / ConstLayout.sizeM) /
                      ConstAnimation.tableTopSecondaryCircleDivisor,
                  phaseY:
                      (ConstLayout.sizeXS / ConstLayout.sizeS) /
                      ConstAnimation.tableTopSecondaryCircleDivisor,
                  amplitudeX: ConstLayout.scaleSmall,
                  amplitudeY: ConstLayout.scaleTiny,
                ),
                diameter:
                    circleSizeHuge /
                    ConstAnimation.tableTopSecondaryCircleDivisor,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the waiting-state loading indicator used by [Screen].
  Widget _displayWaiting() {
    return SizedBox(
      width: ConstLayout.waitingWidgetSize,
      height: ConstLayout.waitingWidgetSize,
      child: Center(
        child: CupertinoActivityIndicator(radius: ConstLayout.sizeXL),
      ),
    );
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
      logger.e('Error getting package info: $e');
      if (mounted) {
        setState(() {
          _version = '1.0.0';
        });
      }
    }
  }

  /// Computes orbital alignment coordinates for ambient overlay animations.
  Alignment _orbitAlignment({
    required double progress,
    required double phaseX,
    required double phaseY,
    required double amplitudeX,
    required double amplitudeY,
  }) {
    final double fullTurn = math.pi * ConstLayout.strokeS;
    final double x = math.sin((progress + phaseX) * fullTurn) * amplitudeX;
    final double y = math.cos((progress + phaseY) * fullTurn) * amplitudeY;
    return Alignment(x, y);
  }
}
