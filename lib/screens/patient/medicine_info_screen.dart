import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/patient_scaffold.dart';
import '../../services/gpt_medicine_service.dart';

class MedicineInfoScreen extends StatefulWidget {
  const MedicineInfoScreen({super.key});

  @override
  State<MedicineInfoScreen> createState() => _MedicineInfoScreenState();
}

class _MedicineInfoScreenState extends State<MedicineInfoScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _medicines = [];
  Map<String, Map<String, String>> _results = {};
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // If empty, clear results
    if (value.trim().isEmpty) {
      setState(() {
        _medicines = [];
        _results = {};
        _errorMessage = null;
      });
      return;
    }
    
    // Set new timer for debounce (600ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _searchMedicines();
    });
  }

  Future<void> _searchMedicines() async {
    final names = _controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errorMessage = l10n?.pleaseEnterAtLeastOneMedicine ??
            'Please enter at least one medicine name';
      });
      return;
    }

    setState(() {
      _medicines = names;
      _results = {};
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await GptMedicineService.getMultipleMedicineInfo(names);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        final l10n = AppLocalizations.of(context);
        _errorMessage =
            '${l10n?.errorFetchingMedicineInfo ?? 'Error fetching medicine information'}: ${e.toString()}';
        _results = {
          for (var name in names)
            name: {
              'sideEffects': l10n?.errorFetchingInformation ??
                  'Error fetching information',
              'contraindications': '',
              'specialInstructions': '',
              'generalInfo':
                  '${l10n?.unableToFetchInfo ?? 'Unable to fetch information'} for $name',
            }
        };
      });
    }
  }

  Widget _buildInfoCard(String medicineName, Map<String, String> info) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          medicineName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Information
                if (info['generalInfo'] != null &&
                    info['generalInfo']!.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildInfoSection(
                        l10n.generalInformation,
                        info['generalInfo']!,
                        Icons.info_outline,
                        Colors.blue,
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Side Effects
                if (info['sideEffects'] != null &&
                    info['sideEffects']!.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildInfoSection(
                        l10n.sideEffects,
                        info['sideEffects']!,
                        Icons.warning_amber_rounded,
                        Colors.orange,
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Contraindications
                if (info['contraindications'] != null &&
                    info['contraindications']!.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildInfoSection(
                        l10n.contraindications,
                        info['contraindications']!,
                        Icons.block,
                        Colors.red,
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Special Instructions
                if (info['specialInstructions'] != null &&
                    info['specialInstructions']!.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return _buildInfoSection(
                        l10n.specialInstructions,
                        info['specialInstructions']!,
                        Icons.medical_information,
                        Colors.green,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PatientScaffold(
      title: l10n.medicineInformation,
      currentRoute: '/medicine-info',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.searchMedicineInformation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: l10n.enterMedicineNames,
                        hintText: l10n.medicineNameHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.medication),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _debounceTimer?.cancel();
                                  _controller.clear();
                                  setState(() {
                                    _medicines = [];
                                    _results = {};
                                    _errorMessage = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {}); // Rebuild to show/hide clear button
                        _onSearchChanged(value); // Debounced search
                      },
                      onSubmitted: (_) {
                        _debounceTimer?.cancel(); // Cancel debounce on submit
                        _searchMedicines();
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _searchMedicines,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                            _isLoading ? l10n.searching : l10n.getMedicineInfo),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results Section
            if (_medicines.isNotEmpty)
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(l10n.searchingMedicineInfo),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Text(l10n.noResultsFound),
                          )
                        : ListView.builder(
                            itemCount: _medicines.length,
                            itemBuilder: (context, index) {
                              final name = _medicines[index];
                              final info = _results[name] ??
                                  {
                                    'sideEffects': 'Loading...',
                                    'contraindications': '',
                                    'specialInstructions': '',
                                    'generalInfo': '',
                                  };
                              return _buildInfoCard(name, info);
                            },
                          ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication_liquid,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.emptyStateNoMedicines,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.emptyStateMedicinesSubtext,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
