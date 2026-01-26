import 'package:cards/screens/screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'VTeam Cards',
      isWaiting: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                SizedBox(height: 20),
                MenuButton(
                  label: 'Join an Existing Game',
                  icon: Icons.group_add,
                  onPressed: () => Navigator.pushNamed(context, '/join'),
                ),
                SizedBox(height: 20),
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
  final String label;

  ///
  final IconData icon;

  ///
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.withAlpha(200),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),

            side: BorderSide(color: Colors.green[600]!, width: 2),
          ),
          elevation: 8,
          shadowColor: Colors.black45,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.yellow.shade300),
            SizedBox(width: 16),
            SizedBox(width: 200, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
