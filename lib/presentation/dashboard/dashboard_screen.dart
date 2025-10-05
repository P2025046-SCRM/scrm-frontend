import 'package:flutter/material.dart';
import 'package:scrm/common/styles/text_styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dashboard', style: kTitleTextStyle,),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {},
              child: CircleAvatar(
          backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
            ),
          ),
        ],
      ),
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
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text('Porcentaje de Materiales Reutilizables', style: kRegularTextStyle,),
              Text('Reciclable: 80%    |    No Reciclable: 20%', style: kDescriptionTextStyle,),
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text('1240', style: kTitleTextStyle,),
                      SizedBox(height: 2,),
                      Text('Unidades de Residuos Procesadas', style: kRegularTextStyle,),
                    ],
                  )
                ],
              ),
              SizedBox(height: 25,),
              Container(
                height: 200,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text('Residuos Reutilizables por Tipo', style: kRegularTextStyle,),
              Text('Retazos: 40% | Biomasa: 30% | Metales: 10% | Piezas Plásticas: 5%', style: kDescriptionTextStyle,),
              SizedBox(height: 25,),
              Container(
                height: 200,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text('Porcentaje de Aciertos', style: kRegularTextStyle,),
              Text('Alto (91.25%)', style: kDescriptionTextStyle,),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Clasificar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.green,
        onTap: (index) { },
      ),
    );
  }
}