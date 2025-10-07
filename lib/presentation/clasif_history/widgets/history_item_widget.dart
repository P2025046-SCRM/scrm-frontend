import 'package:flutter/material.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/item_thumbnail_widget.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({
    super.key,
    required this.imagePath,
    required this.layer1,
    required this.layer2,
    required this.classifTime,
    required this.confidence,
  });
  final String imagePath;
  final String layer1;
  final String layer2;
  final String classifTime;
  final double confidence;

  _wasteType(String layer1, String layer2) {
    String recycleType = '';
    if (layer1 == 'No Reciclable') {
      return layer1;
    } else if (layer1 == 'Reciclable') {
      switch (layer2) {
        case 'Retazo de Madera':
          recycleType = 'Interno';
          break;
        case 'Biomasa':
          recycleType = 'Externo';
          break;
        case 'Metal':
          recycleType = 'Externo';
          break;
        case 'Pieza Plástica':
          recycleType = 'Interno';
          break;
        default:
      }
      return '$layer1 - $recycleType';
    } else {
      return layer1;
    }
  }

  @override
  Widget build(BuildContext context) {
    double showConfidence = (confidence * 100).roundToDouble();
    String shownLabel = _wasteType(layer1, layer2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          ItemThumbnail(imagePath: imagePath,),
          SizedBox(width: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$shownLabel • $showConfidence%', style: kRegularTextStyle,),
              SizedBox(height: 5,),
              Text(layer2, style: kTextButtonStyle,),
              SizedBox(height: 5,),
              Text(classifTime, style: kTextButtonStyle,),
            ],
          )
        ],
      ),
    );
  }
}