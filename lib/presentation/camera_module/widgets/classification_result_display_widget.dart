import 'package:flutter/material.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/common/widgets/item_thumbnail_widget.dart';
import 'package:scrm/utils/constants.dart';
import 'action_button_widget.dart';

class ClassificationResultDisplay extends StatelessWidget {
  const ClassificationResultDisplay({
    super.key,
    required this.imagePath,
    required this.isCurrentImageAsset,
    this.layer1,
    this.layer2,
    this.layer1ConfidenceText,
    this.layer2ConfidenceText,
    this.wasteLabel,
    this.hasMultipleCameras = false,
    this.onSwitchCamera,
  });

  final String imagePath;
  final bool isCurrentImageAsset;
  final String? layer1;
  final String? layer2;
  final String? layer1ConfidenceText;
  final String? layer2ConfidenceText;
  final String? wasteLabel;
  final bool hasMultipleCameras;
  final VoidCallback? onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          ItemThumbnail(
            imagePath: imagePath,
            isAsset: isCurrentImageAsset,
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only show layer1 result and confidence if data exists
              if (layer1 != null && layer1ConfidenceText != null)
                Text(
                  '${layer1 == WasteTypes.noReciclable ? 'No Reciclable' : layer1} • $layer1ConfidenceText%',
                  style: kSubtitleTextStyle,
                ),
              // Only show layer2 line (class, Interno/Externo label, and confidence) when layer1 is Reciclable and data exists
              if (layer1 == WasteTypes.reciclable &&
                  layer2 != null &&
                  layer2!.isNotEmpty &&
                  layer2ConfidenceText != null &&
                  wasteLabel != null) ...[
                if (layer1 != null && layer1ConfidenceText != null)
                  const SizedBox(height: 10),
                Text(
                  '$layer2 • $wasteLabel • $layer2ConfidenceText%',
                  style: kRegularTextStyle,
                ),
              ],
            ],
          ),
          const Spacer(),
          if (hasMultipleCameras && onSwitchCamera != null)
            ActionIconButton(
              onPressed: onSwitchCamera,
              icon: Icons.cameraswitch_outlined,
            )
          else
            const SizedBox(width: 1),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

