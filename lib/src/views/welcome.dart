import 'package:flutter/material.dart';
import 'package:youth_card/l10n/app_localizations.dart';

class Welcome extends StatelessWidget {


  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF143E42),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Image.asset('images/colortextlogo.png', height: 180),
              ),
              const SizedBox(height: 32),
              Text(AppLocalizations.of(context)!.discover,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  )),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(AppLocalizations.of(context)!.btnContinue),
                ),
              ),
              const SizedBox(height: 24),
              Image.asset('images/erasmusplus.png', height: 42),
            ],
          ),
        ),
      ),
    );
  }
}
