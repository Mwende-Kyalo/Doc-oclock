import 'package:flutter/material.dart';
import '../widgets/patient_drawer.dart';

class PatientScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final String currentRoute;

  const PatientScaffold({
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
      drawer: PatientDrawer(currentRoute: currentRoute),
      body: body,
    );
  }
}

