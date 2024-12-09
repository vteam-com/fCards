import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

const version = '1.5.2';

class ResponsiveBreakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

extension DeviceType on BuildContext {
  bool get isPhone =>
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.phone;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.phone &&
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.tablet;
  bool get isDesktop =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.desktop;
}

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.title,
    required this.child,
    this.onRefresh,
    this.getLinkToShare,
    this.rightText = '',
    required this.isWaiting,
  });
  final String title;
  final String rightText;
  final Widget child;
  final Function? onRefresh;
  final String Function()? getLinkToShare;
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
                Share.share(getLinkToShare!());
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
