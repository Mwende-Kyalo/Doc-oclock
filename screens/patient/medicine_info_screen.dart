import 'package:flutter/material.dart';
import '../../widgets/patient_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicineInfoScreen extends StatefulWidget {
  const MedicineInfoScreen({Key? key}) : super(key: key);

  @override
  State<MedicineInfoScreen> createState() => _MedicineInfoScreenState();
}

class _MedicineInfoScreenState extends State<MedicineInfoScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _medicines = [];
  Map<String, Map<String, String>> _results = {};

  Future<void> _searchMedicines() async {
    final names = _controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    setState(() {
      _medicines = names;
      _results = {};
    });

    if (names.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/USSD/application_backend/medicine_info.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'medicines': names}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null) {
          setState(() {
            _results = Map<String, Map<String, String>>.from(
                (data['results'] as Map).map((key, value) =>
                    MapEntry(key, Map<String, String>.from(value))));
          });
        }
      } else {
        setState(() {
          _results = {
            for (var name in names)
              name: {
                'sideEffects': 'Error fetching info.',
                'recommendations': '',
                'suggestions': ''
              }
          };
        });
      }
    } catch (e) {
      setState(() {
        _results = {
          for (var name in names)
            name: {
              'sideEffects': 'Error connecting to backend.',
              'recommendations': '',
              'suggestions': ''
            }
        };
      });
    }
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    return PatientScaffold(
      title: 'Medicine Info',
      currentRoute: '/medicine-info', // Adjust route as needed
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter medicine names (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _searchMedicines,
              child: const Text('Show Info'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  final name = _medicines[index];
                  final info = _results[name]!;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Side Effects: ${info['sideEffects']}'),
                          Text('Recommendations: ${info['recommendations']}'),
                          Text('Suggestions: ${info['suggestions']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
