import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/data/providers/dashboard_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/utils/logger.dart';

import '../../common/widgets/appbar_widget.dart';
import '../../common/widgets/bottom_nav_bar_widget.dart';
import '../clasif_history/widgets/empty_state_widget.dart';
import 'widgets/stats_counter_widget.dart';
import 'widgets/pie_chart_card_widget.dart';
import 'widgets/bar_chart_card_widget.dart';
import 'widgets/gauge_chart_card_widget.dart';
import 'widgets/percentage_display_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (userProvider.currentUser == null || userProvider.userName == null) {
        userProvider.fetchUserData().then((_) {
          final companyName = userProvider.userCompany ?? '3J Solutions';
          dashboardProvider.fetchStatistics(companyName: companyName);
        }).catchError((e, stackTrace) {
          AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to fetch user data in dashboard');
          dashboardProvider.fetchStatistics(companyName: '3J Solutions');
        });
      } else {
        final companyName = userProvider.userCompany ?? '3J Solutions';
        dashboardProvider.fetchStatistics(companyName: companyName);
      }
    });
  }

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
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final userName = userProvider.userName ?? 'Usuario';
                  return Text('Hola, $userName', style: kSubtitleTextStyle,);
                },
              ),
              SizedBox(height: 20,),
              Consumer<DashboardProvider>(
                builder: (context, dashboardProvider, _) {
                  if (dashboardProvider.isLoading && dashboardProvider.statistics == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (dashboardProvider.statistics == null || dashboardProvider.totalProcessed == 0) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 150.0),
                        child: EmptyStateWidget(
                          icon: Icons.bar_chart,
                          message: 'No hay información disponible.\nEmpiece a clasificar residuos para ver estadísticas',
                        ),
                      ),
                    );
                  }
                  
                  final recyclablePercent = dashboardProvider.recyclablePercentage;
                  final nonRecyclablePercent = dashboardProvider.nonRecyclablePercentage;
                  final barData = dashboardProvider.wasteTypeDistribution;
                  final percentages = dashboardProvider.getMaterialPercentages();
                  final accuracy = dashboardProvider.accuracyPercentage;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PieChartCard(
                        recyclablePercent: recyclablePercent,
                        nonRecyclablePercent: nonRecyclablePercent,
                      ),
                      const SizedBox(height: 8,),
                      RecyclablePercentageDisplayWidget(
                        recyclablePercent: recyclablePercent,
                        nonRecyclablePercent: nonRecyclablePercent,
                      ),
                      const SizedBox(height: 25,),
                      StatsCounter(
                        count: dashboardProvider.totalProcessed,
                        statLabel: 'Unidades de Residuos Procesadas',
                      ),
                      const SizedBox(height: 25,),
                      BarChartCard(barData: barData),
                      const SizedBox(height: 8,),
                      PercentageDisplayWidget(
                        title: 'Residuos Reutilizables por Tipo',
                        percentages: percentages,
                      ),
                      const SizedBox(height: 25,),
                      GaugeChartCard(accuracy: accuracy),
                      AccuracyPercentageDisplayWidget(accuracy: accuracy),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0,),
    );
  }
}
