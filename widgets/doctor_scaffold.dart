import 'package:flutter/material.dart';
import '../widgets/doctor_drawer.dart';

class DoctorScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final String currentRoute;

  const DoctorScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: DoctorDrawer(currentRoute: currentRoute),
      body: body,
    );
  }
}

