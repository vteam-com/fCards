import 'package:cards/screens/screen.dart';
import 'package:flutter/material.dart';

/// Welcome screen that provides options to start new game, join existing game, or keep scores.
class MainMenu extends StatelessWidget {
  ///
  const MainMenu({super.key});

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
                const SizedBox(height: 20),
                MenuButton(
                  label: 'Join an Existing Game',
                  icon: Icons.group_add,
                  onPressed: () => Navigator.pushNamed(context, '/join'),
                ),
                const SizedBox(height: 20),
                MenuButton(
                  label: 'Scorekeeper',
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
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            const SizedBox(width: 16),
            SizedBox(width: 200, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
