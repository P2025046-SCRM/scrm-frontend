import 'package:flutter/material.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/common/widgets/card_container_widget.dart';
import 'package:scrm/utils/constants.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'indicator_widget.dart';

class GaugeChartCard extends StatelessWidget {
  const GaugeChartCard({
    super.key,
    required this.accuracy,
  });

  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      height: 200,
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 60,
                      color: AppColors.nonRecyclableRed,
                    ),
                    GaugeRange(
                      startValue: 60,
                      endValue: 85,
                      color: Colors.orange,
                    ),
                    GaugeRange(
                      startValue: 85,
                      endValue: 100,
                      color: AppColors.recyclableGreen,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: accuracy,
                      needleLength: 0.95,
                      needleEndWidth: 7,
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        '${accuracy.toStringAsFixed(2)}%',
                        style: kSubtitleTextStyle,
                      ),
                      angle: 90,
                      positionFactor: 0.8,
                    )
                  ],
                )
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Indicator(
                color: AppColors.nonRecyclableRed,
                text: 'Bajo (<60%)',
                isSquare: false,
              ),
              SizedBox(height: 12),
              Indicator(
                color: Colors.orange,
                text: 'Medio (<85%)',
                isSquare: false,
              ),
              SizedBox(height: 12),
              Indicator(
                color: AppColors.recyclableGreen,
                text: 'Alto (>85%)',
                isSquare: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

