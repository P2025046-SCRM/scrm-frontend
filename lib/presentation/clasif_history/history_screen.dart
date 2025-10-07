import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/appbar_widget.dart';
import 'package:scrm/common/widgets/bottom_nav_bar_widget.dart';
import 'widgets/history_item_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Dummy data list, replace with actual data from backend/API
  final List<Map<String, dynamic>> historyData = [
    {
      'imagePath': 'assets/sample_wood_image.jpg',
      'layer1': 'Reciclable',
      'layer2': 'Retazo de Madera',
      'classifTime': '2025-09-19 14:30',
      'confidence': 0.95,
    },
    {
      'imagePath': 'assets/sample_plastic_image.jpg',
      'layer1': 'Reciclable',
      'layer2': 'Pieza Plástica',
      'classifTime': '2025-09-18 11:20',
      'confidence': 0.893,
    },
    {
      'imagePath': 'assets/sample_metal_image.jpg',
      'layer1': 'Reciclable',
      'layer2': 'Metal',
      'classifTime': '2025-09-17 09:10',
      'confidence': 0.921,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Historial de Residuos', showProfile: true),
      body: Column(
        children: historyData.map((item) => HistoryListItem(
          imagePath: item['imagePath'],
          layer1: item['layer1'],
          layer2: item['layer2'],
          classifTime: item['classifTime'],
          confidence: item['confidence'],
        )).toList(),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
