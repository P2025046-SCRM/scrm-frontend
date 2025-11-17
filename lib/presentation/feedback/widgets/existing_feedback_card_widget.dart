import 'package:flutter/material.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/common/widgets/card_container_widget.dart';
import 'package:scrm/utils/constants.dart';

class ExistingFeedbackCard extends StatelessWidget {
  const ExistingFeedbackCard({
    super.key,
    required this.existingFeedback,
    required this.modelFormatToDisplayFormat,
    required this.formatReviewedAtDate,
  });

  final Map<String, dynamic> existingFeedback;
  final String? Function(String?)? modelFormatToDisplayFormat;
  final String Function(dynamic) formatReviewedAtDate;

  @override
  Widget build(BuildContext context) {
    final isCorrect = existingFeedback['is_correct'] == true;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revisión del Operador', style: kSubtitleTextStyle),
          const SizedBox(height: 12),
          // Status: Correcto/Incorrecto
          Row(
            children: [
              Text('Estado: ', style: kRegularTextStyle),
              Text(
                isCorrect ? 'Correcto' : 'Incorrecto',
                style: kRegularTextStyle.copyWith(
                  color: isCorrect
                      ? AppColors.recyclableGreen
                      : AppColors.nonRecyclableRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Correct classification if Incorrecto
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            if (existingFeedback['correct_l1_class'] != null) ...[
              Text(
                'Clasificación Correcta: ${existingFeedback['correct_l1_class'] == WasteTypes.noReciclable ? 'No Reciclable' : existingFeedback['correct_l1_class']}',
                style: kRegularTextStyle,
              ),
              if (existingFeedback['correct_l2_class'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Clase: ${modelFormatToDisplayFormat?.call(existingFeedback['correct_l2_class']) ?? existingFeedback['correct_l2_class']}',
                  style: kRegularTextStyle,
                ),
              ],
            ],
          ],
          // Reviewed at date
          if (existingFeedback['reviewed_at'] != null) ...[
            const SizedBox(height: 8),
            Text(
              formatReviewedAtDate(existingFeedback['reviewed_at']),
              style: kDescriptionTextStyle,
            ),
          ],
          // Notes if exists
          if (existingFeedback['notes'] != null &&
              (existingFeedback['notes'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notas:', style: kRegularTextStyle),
            const SizedBox(height: 4),
            Text(
              existingFeedback['notes'] as String,
              style: kDescriptionTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}

