import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../common/widgets/appbar_widget.dart';
import '../../common/widgets/bottom_nav_bar_widget.dart';
import 'widgets/indicator_widget.dart';
import 'widgets/stats_counter_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final List<double> barData = const [40, 26, 16, 19]; // input data for bars

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Dashboard', showProfile: true,),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, Juan Perez', style: kSubtitleTextStyle,),
              SizedBox(height: 20,),
              Container(
                height: 200,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: List<BoxShadow>.generate(
                    3,
                    (index) => BoxShadow(
                    color: const Color.fromARGB(33, 0, 0, 0),
                    blurRadius: 2 * (index + 1),
                    offset: Offset(0,2 * (index + 1))
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: 80,
                              title: 'Reciclable',
                              showTitle: false,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              color: Colors.red,
                              value: 20,
                              title: 'No Reciclable',
                              showTitle: false,
                              radius: 50,
                            ),
                          ],
                          sectionsSpace: 0,
                        ),
                        duration: Duration(milliseconds: 150),
                        curve: Curves.linear,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Indicator(
                          color: Colors.green,
                          text: 'Reutilizable',
                          isSquare: false,
                        ),
                        const Indicator(
                          color: Colors.red,
                          text: 'No Reutilizable',
                          isSquare: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Text('Porcentaje de Materiales Reutilizables', style: kRegularTextStyle,),
              Text('Reciclable: 80%    |    No Reciclable: 20%', style: kDescriptionTextStyle,),
              SizedBox(height: 25,),
              StatsCounter(count: 1240, statLabel: 'Unidades de Residuos Procesadas',), // Pass actual data here
              SizedBox(height: 25,),
              Container(
                height: 220,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: List<BoxShadow>.generate(
                  3,
                  (index) => BoxShadow(
                    color: const Color.fromARGB(33, 0, 0, 0),
                    blurRadius: 2 * (index + 1),
                    offset: Offset(0, 2 * (index + 1)),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Horizontal legend with scroll for small screens
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Indicator(
                              color: Color.fromARGB(255, 193, 123, 25),
                              text: 'Retazos',
                              isSquare: false,
                            ),
                            SizedBox(width: 16),
                            Indicator(
                              color: Color.fromARGB(255, 71, 178, 29),
                              text: 'Biomasa',
                              isSquare: false,
                            ),
                            SizedBox(width: 16),
                            Indicator(
                              color: Color.fromARGB(255, 146, 155, 170),
                              text: 'Metales',
                              isSquare: false,
                            ),
                            SizedBox(width: 16),
                            Indicator(
                              color: Color.fromARGB(255, 6, 17, 167),
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
                          reservedSize: 50, // Wider Y axis for title
                          getTitlesWidget: (value, meta) {
                            // Show only integer ticks, e.g. every 10 units
                            if (value % 10 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 12),
                            );
                            }
                            return SizedBox.shrink();
                          },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      maxY: 40, // <-- Adjust to maxY based on data
                      minY: 0,
                        barGroups: List.generate(
                        barData.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                          BarChartRodData(
                            toY: barData[i],
                            color: [
                            const Color.fromARGB(255, 193, 123, 25),
                            const Color.fromARGB(255, 71, 178, 29),
                            const Color.fromARGB(255, 146, 155, 170),
                            const Color.fromARGB(255, 6, 17, 167),
                            ][i % 4], // Assign a different color for each bar
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
              ),
              SizedBox(height: 8,),
              Text('Residuos Reutilizables por Tipo', style: kRegularTextStyle,),
              Text('Retazos: 40% | Biomasa: 30% | Metales: 10% | Piezas Plásticas: 5%', style: kDescriptionTextStyle,),
              SizedBox(height: 25,),
              Container(
                height: 200,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: List<BoxShadow>.generate(
                  3,
                  (index) => BoxShadow(
                    color: const Color.fromARGB(33, 0, 0, 0),
                    blurRadius: 2 * (index + 1),
                    offset: Offset(0, 2 * (index + 1)),
                    ),
                  ),
                ),
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
                              GaugeRange(startValue: 0, endValue: 60, color: Colors.red),
                              GaugeRange(startValue: 60, endValue: 85, color: Colors.orange),
                              GaugeRange(startValue: 85, endValue: 100, color: Colors.green),
                            ],
                            pointers: <GaugePointer>[
                              NeedlePointer(value: 91.25, needleLength: 0.95, needleEndWidth: 7,) // replace needle value with actual accuracy here
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                widget: Text('91.25%', style: kTitleTextStyle,),
                                angle: 90,
                                positionFactor: 0.5
                              )
                            ]
                          )
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Indicator(
                          color: Colors.red,
                          text: 'Bajo (<60%)',
                          isSquare: false,
                        ),
                        SizedBox(height: 12),
                        const Indicator(
                          color: Colors.orange,
                          text: 'Medio (<85%)',
                          isSquare: false,
                        ),
                        SizedBox(height: 12),
                        const Indicator(
                          color: Colors.green,
                          text: 'Alto (>85%)',
                          isSquare: false,
                        ),                        
                      ],
                    ),
                  ],
                ),
              ),
              Text('Porcentaje de Aciertos', style: kRegularTextStyle,),
              Text('Alto (91.25%)', style: kDescriptionTextStyle,),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0,),
    );
  }
}
