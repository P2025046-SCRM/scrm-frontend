import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/data/providers/admin_dashboard_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/utils/constants.dart' show WasteTypes;

import '../../common/widgets/appbar_widget.dart';
import 'widgets/kpi_card_widget.dart';
import 'widgets/gauge_chart_card_widget.dart';
import 'widgets/bar_chart_card_widget.dart';
import 'widgets/percentage_display_widget.dart';

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
                    return const Center(child: CircularProgressIndicator());
                  }
                  final accuracy = adminDashboardProvider.globalAccuracyPercentage;
                  
                  return GaugeChartCard(accuracy: accuracy);
                },
              ),
              SizedBox(height: 8,),
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  final accuracy = adminDashboardProvider.globalAccuracyPercentage;
                  
                  return AccuracyPercentageDisplayWidget(
                    accuracy: accuracy,
                    showGlobalLabel: true,
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Inference
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return KPICard(
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
                  return KPICard(
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
                  return KPICard(
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
                  
                  return BarChartCard(barData: barData);
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
                          '${WasteTypes.retazos}: 0%  |  ${WasteTypes.biomasa}: 0%  |  ${WasteTypes.metales}: 0%  |  Plásticos: 0%',
                          style: kDescriptionTextStyle,
                        ),
                      ],
                    );
                  }
                  
                  final percentageMap = {
                    'retazos': (percentages[0] / total * 100),
                    'biomasa': (percentages[1] / total * 100),
                    'metales': (percentages[2] / total * 100),
                    'plasticos': (percentages[3] / total * 100),
                  };
                  
                  return PercentageDisplayWidget(
                    title: 'Residuos Reutilizables por Tipo',
                    percentages: percentageMap,
                    showGlobalLabel: true,
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Predictions
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return KPICard(
                    count: adminDashboardProvider.totalPredictions.toString(),
                    label: 'Predicciones Totales',
                  );
                },
              ),
              SizedBox(height: 15,),
              // Active Companies
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return KPICard(
                    count: adminDashboardProvider.totalCompanies.toString(),
                    label: 'Compañias Activas',
                  );
                },
              ),
              SizedBox(height: 15,),
              // Total Users
              Consumer<AdminDashboardProvider>(
                builder: (context, adminDashboardProvider, _) {
                  return KPICard(
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
}

