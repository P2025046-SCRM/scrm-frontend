import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          label: 'Clasificar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historial',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.green,
      onTap: (index) {
        if (index == currentIndex) return; // Do nothing if the same tab is tapped
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, 'dashboard');
            break;
          case 1:
            Navigator.pushNamed(context, 'camera');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, 'history');
            break;
        }
      },
    );
  }
}
