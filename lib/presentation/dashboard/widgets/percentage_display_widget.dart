import 'package:flutter/material.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/utils/constants.dart' show WasteTypes;

class PercentageDisplayWidget extends StatelessWidget {
  const PercentageDisplayWidget({
    super.key,
    required this.title,
    required this.percentages,
    this.showGlobalLabel = false,
  });

  final String title;
  final Map<String, double> percentages;
  final bool showGlobalLabel;

  @override
  Widget build(BuildContext context) {
    String globalText = showGlobalLabel ? ' (Global)' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title$globalText', style: kRegularTextStyle),
        Text(
          '${WasteTypes.retazos}: ${percentages['retazos']!.toStringAsFixed(0)}%  |  '
          '${WasteTypes.biomasa}: ${percentages['biomasa']!.toStringAsFixed(0)}%  |  '
          '${WasteTypes.metales}: ${percentages['metales']!.toStringAsFixed(0)}%  |  '
          'Plásticos: ${percentages['plasticos']!.toStringAsFixed(0)}%',
          style: kDescriptionTextStyle,
        ),
      ],
    );
  }
}

class RecyclablePercentageDisplayWidget extends StatelessWidget {
  const RecyclablePercentageDisplayWidget({
    super.key,
    required this.recyclablePercent,
    required this.nonRecyclablePercent,
  });

  final double recyclablePercent;
  final double nonRecyclablePercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Porcentaje de Materiales Reutilizables', style: kRegularTextStyle),
        Text(
          '${WasteTypes.reciclable}: ${recyclablePercent.toStringAsFixed(0)}%    |    ${WasteTypes.noReciclable}: ${nonRecyclablePercent.toStringAsFixed(0)}%',
          style: kDescriptionTextStyle,
        ),
      ],
    );
  }
}

class AccuracyPercentageDisplayWidget extends StatelessWidget {
  const AccuracyPercentageDisplayWidget({
    super.key,
    required this.accuracy,
    this.showGlobalLabel = false,
  });

  final double accuracy;
  final bool showGlobalLabel;

  @override
  Widget build(BuildContext context) {
    String accuracyLevel;
    if (accuracy >= 85) {
      accuracyLevel = 'Alto';
    } else if (accuracy >= 60) {
      accuracyLevel = 'Medio';
    } else {
      accuracyLevel = 'Bajo';
    }

    String globalText = showGlobalLabel ? ' (Global)' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Porcentaje de Aciertos$globalText', style: kRegularTextStyle),
        Text(
          '$accuracyLevel (${accuracy.toStringAsFixed(2)}%)',
          style: kDescriptionTextStyle,
        ),
      ],
    );
  }
}

