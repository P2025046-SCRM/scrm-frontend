import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/card_container_widget.dart';
import 'package:scrm/utils/constants.dart';
import 'indicator_widget.dart';

class BarChartCard extends StatelessWidget {
  const BarChartCard({
    super.key,
    required this.barData,
  });

  final List<double> barData;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      height: 220,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Indicator(
                    color: AppColors.retazosOrange,
                    text: WasteTypes.retazos,
                    isSquare: false,
                  ),
                  SizedBox(width: 16),
                  Indicator(
                    color: AppColors.biomasaGreen,
                    text: WasteTypes.biomasa,
                    isSquare: false,
                  ),
                  SizedBox(width: 16),
                  Indicator(
                    color: AppColors.metalesGray,
                    text: WasteTypes.metales,
                    isSquare: false,
                  ),
                  SizedBox(width: 16),
                  Indicator(
                    color: AppColors.plasticosBlue,
                    text: 'Plásticos',
                    isSquare: false,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value % 10 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                maxY: barData.isEmpty
                    ? 40
                    : (barData.reduce((a, b) => a > b ? a : b) * 1.2).ceil().toDouble(),
                minY: 0,
                barGroups: List.generate(
                  barData.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: barData.isEmpty ? 0.0 : barData[i],
                        color: [
                          AppColors.retazosOrange,
                          AppColors.biomasaGreen,
                          AppColors.metalesGray,
                          AppColors.plasticosBlue,
                        ][i % 4],
                        width: 25,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

