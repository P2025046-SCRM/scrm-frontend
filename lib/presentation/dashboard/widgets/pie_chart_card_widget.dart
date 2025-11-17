import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/card_container_widget.dart';
import 'package:scrm/utils/constants.dart';
import 'indicator_widget.dart';

class PieChartCard extends StatelessWidget {
  const PieChartCard({
    super.key,
    required this.recyclablePercent,
    required this.nonRecyclablePercent,
  });

  final double recyclablePercent;
  final double nonRecyclablePercent;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      height: 200,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: AppColors.recyclableGreen,
                    value: recyclablePercent,
                    title: WasteTypes.reciclable,
                    showTitle: false,
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: AppColors.nonRecyclableRed,
                    value: nonRecyclablePercent,
                    title: WasteTypes.noReciclable,
                    showTitle: false,
                    radius: 50,
                  ),
                ],
                sectionsSpace: 0,
              ),
              duration: const Duration(milliseconds: 150),
              curve: Curves.linear,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Indicator(
                color: AppColors.recyclableGreen,
                text: 'Reutilizable',
                isSquare: false,
              ),
              Indicator(
                color: AppColors.nonRecyclableRed,
                text: 'No Reutilizable',
                isSquare: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

