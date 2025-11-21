import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Telemedicine App',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text('Sign in as Patient'),
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/doctor-sign-in'),
                child: const Text('Sign in as Doctor'),
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
