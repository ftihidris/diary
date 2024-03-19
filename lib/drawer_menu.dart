import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    required this.isDarkMode,
    required this.onToggleThemeMode,
  });

  final bool isDarkMode;
  final void Function() onToggleThemeMode;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.black54 : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.grey[200],
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 30,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    isDarkMode ? Icons.brightness_6 : Icons.brightness_3,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  SizedBox(width: 16),
                  Text(
                    isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              onTap: () {
                onToggleThemeMode();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
