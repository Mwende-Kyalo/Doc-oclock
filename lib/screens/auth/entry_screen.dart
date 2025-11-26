import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.welcomeToApp,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/sign-in'),
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
                child: Text(l10n.signInAsPatient),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/sign-up'),
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
                child: Text(l10n.signUpAsPatient),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/doctor-sign-in'),
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
                child: Text(l10n.signInAsDoctor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
