import 'package:cards/models/app/constants.dart';
import 'package:cards/widgets/helpers/screen.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Welcome screen that provides options to start new game, join existing game, or keep scores.
class MainMenu extends StatefulWidget {
  ///
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    // Check if we have URL parameters that should redirect to game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUrlParameters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'VTeam Cards',
      isWaiting: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Constants.mainMenuMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(Constants.sizeM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                MenuButton(
                  label: 'Start a New Game',
                  icon: Icons.play_circle_fill,
                  onPressed: () => Navigator.pushNamed(context, '/game'),
                ),
                SizedBox(height: Constants.sizeM),
                MenuButton(
                  label: 'Join an Existing Game',
                  icon: Icons.group_add,
                  onPressed: () => Navigator.pushNamed(context, '/join'),
                ),
                SizedBox(height: Constants.sizeM),
                MenuButton(
                  label: 'Score Keeper',
                  icon: Icons.scoreboard,
                  onPressed: () => Navigator.pushNamed(context, '/score'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkForUrlParameters() {
    if (!kIsWeb) {
      return; // Only check on web
    }

    final uri = Uri.parse(Uri.base.toString());
    if (uri.queryParameters.isNotEmpty) {
      // We have query parameters, redirect to start screen which can handle them
      // Use Future.delayed to ensure context is available
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/game');
        }
      });
    }
  }
}

/// A styled button for the main menu.
class MenuButton extends StatelessWidget {
  ///
  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  ///
  final IconData icon;

  ///
  final String label;

  ///
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Constants.mainMenuButtonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.withAlpha(Constants.alpha200),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.sizeL,
            vertical: Constants.sizeM,
          ),

          textStyle: TextStyle(
            fontSize: Constants.textM,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.radiusL),

            side: BorderSide(
              color: Constants.primaryGreenLight,
              width: Constants.strokeS,
            ),
          ),
          elevation: Constants.elevationL,
          shadowColor: Colors.black45,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: Constants.iconM, color: Colors.yellow.shade300),
            SizedBox(width: Constants.sizeM),
            SizedBox(
              width: Constants.mainMenuButtonTextWidth,
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
