import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/data/providers/admin_dashboard_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../common/widgets/appbar_widget.dart';
import 'widgets/indicator_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminDashboardProvider = Provider.of<AdminDashboardProvider>(context, listen: false);
      adminDashboardProvider.fetchGlobalStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Admin Dashboard', showProfile: true,),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final userName = userProvider.userName ?? 'Admin';
                  return Text('Hola, $userName', style: kSubtitleTextStyle,);
                },
              ),
              SizedBox(height: 20,),
              // Gauge Chart
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  if (adminDashboardProvider.isLoading && adminDashboardProvider.statistics == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final accuracy = adminDashboardProvider.globalAccuracyPercentage;
                  
                  return Container(
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
                              NeedlePointer(value: accuracy, needleLength: 0.95, needleEndWidth: 7,)
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                widget: Text('${accuracy.toStringAsFixed(2)}%', style: kSubtitleTextStyle,),
                                angle: 90,
                                positionFactor: 0.8
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
                  );
                },
              ),
              SizedBox(height: 8,),
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  final accuracy = adminDashboardProvider.globalAccuracyPercentage;
                  String accuracyLevel;
                  if (accuracy >= 85) {
                    accuracyLevel = 'Alto';
                  } else if (accuracy >= 60) {
                    accuracyLevel = 'Medio';
                  } else {
                    accuracyLevel = 'Bajo';
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Porcentaje de Aciertos (Global)', style: kRegularTextStyle,),
                      Text('$accuracyLevel (${accuracy.toStringAsFixed(2)}%)', style: kDescriptionTextStyle,),
                    ],
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Inference
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return _buildKPICard(
                    count: adminDashboardProvider.averageTotalInferenceTime.toStringAsFixed(2),
                    label: 'Promedio de Tiempo Total de Inferencia',
                    isDouble: true,
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Inference Layer 1
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return _buildKPICard(
                    count: adminDashboardProvider.averageLayer1InferenceTime.toStringAsFixed(2),
                    label: 'Promedio de Tiempo de Inferencia de Capa 1',
                    isDouble: true,
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Inference Layer 2
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return _buildKPICard(
                    count: adminDashboardProvider.averageLayer2InferenceTime.toStringAsFixed(2),
                    label: 'Promedio de Tiempo de Inferencia de Capa 2',
                    isDouble: true,
                  );
                },
              ),
              SizedBox(height: 25,),
              // Layer 2 Bar Chart
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  final barData = adminDashboardProvider.wasteTypeDistribution;
                  
                  return Container(
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
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
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
                          maxY: barData.isEmpty ? 40 : (barData.reduce((a, b) => a > b ? a : b) * 1.2).ceil().toDouble(),
                          minY: 0,
                          barGroups: List.generate(
                            barData.length,
                            (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: barData.isEmpty ? 0.0 : barData[i],
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
                  );
                },
              ),
              SizedBox(height: 8,),
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  final percentages = adminDashboardProvider.wasteTypeDistribution;
                  final total = percentages.fold<double>(0.0, (acc, value) => acc + value);
                  
                  if (total == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Residuos Reutilizables por Tipo (Global)', style: kRegularTextStyle,),
                        Text(
                          'Retazos: 0%  |  Biomasa: 0%  |  Metales: 0%  |  Plásticos: 0%',
                          style: kDescriptionTextStyle,
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Residuos Reutilizables por Tipo (Global)', style: kRegularTextStyle,),
                      Text(
                        'Retazos: ${(percentages[0] / total * 100).toStringAsFixed(0)}%  |  '
                        'Biomasa: ${(percentages[1] / total * 100).toStringAsFixed(0)}%  |  '
                        'Metales: ${(percentages[2] / total * 100).toStringAsFixed(0)}%  |  '
                        'Plásticos: ${(percentages[3] / total * 100).toStringAsFixed(0)}%',
                        style: kDescriptionTextStyle,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Predictions
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return _buildKPICard(
                    count: adminDashboardProvider.totalPredictions.toString(),
                    label: 'Predicciones Totales',
                  );
                },
              ),
              SizedBox(height: 15,),
              // Active Companies
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return _buildKPICard(
                    count: adminDashboardProvider.totalCompanies.toString(),
                    label: 'Compañias Activas',
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Users
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return _buildKPICard(
                    count: adminDashboardProvider.totalUsers.toString(),
                    label: 'Total de Usuarios',
                  );
                },
              ),
              SizedBox(height: 15,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard({
    required String count,
    required String label,
    bool isDouble = false,
  }) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: kTitleTextStyle,),
              if (isDouble)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 2),
                  child: Text(
                    's',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              style: kRegularTextStyle,
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

