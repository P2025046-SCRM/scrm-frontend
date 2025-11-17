import 'package:flutter/material.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/item_thumbnail_widget.dart';
import '../../../utils/waste_type_helper.dart';
import '../../../utils/constants.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({
    super.key,
    required this.predictionId,
    required this.imagePath,
    required this.layer1,
    required this.layer2,
    required this.classifTime,
    required this.layer1Confidence,
    this.layer2Confidence,
    required this.onTap,
  });
  final String predictionId;
  final String imagePath;
  final String layer1;
  final String layer2;
  final String classifTime;
  final double layer1Confidence;
  final double? layer2Confidence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Format confidences as percentages with one decimal place
    final String layer1ConfidenceText = (layer1Confidence * 100).toStringAsFixed(1);
    final String? layer2ConfidenceText =
        layer2Confidence != null ? (layer2Confidence! * 100).toStringAsFixed(1) : null;
    
    // Get Interno/Externo label for layer2 (only used when Reciclable)
    final String wasteLabel = WasteTypeHelper.getWasteType(layer1, layer2);
    
    // Format layer1 for display (NoReciclable -> No Reciclable)
    final String displayLayer1 = layer1 == WasteTypes.noReciclable ? 'No Reciclable' : layer1;

    final bool isAssetImage = imagePath.isEmpty || (!imagePath.startsWith('http') && !imagePath.startsWith('/'));
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          children: [
            ItemThumbnail(
              imagePath: imagePath.isNotEmpty ? imagePath : 'assets/sample_wood_image.jpg',
              isAsset: isAssetImage,
            ),
            SizedBox(width: 15,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First line: Layer1 result • Layer1 confidence
                  Text(
                    '$displayLayer1 • $layer1ConfidenceText%',
                    style: kSubtitleTextStyle,
                  ),
                  // Second line: Layer2 result • Interno/Externo • Layer2 confidence (only if Reciclable)
                  if (layer1 == WasteTypes.reciclable && layer2.isNotEmpty && layer2ConfidenceText != null) ...[
                    SizedBox(height: 10,),
                    Text(
                      '$layer2 • $wasteLabel • $layer2ConfidenceText%',
                      style: kRegularTextStyle,
                    ),
                  ],
                  // Third line: Date
                  SizedBox(height: 10,),
                  Text(classifTime, style: kTextButtonStyle,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}