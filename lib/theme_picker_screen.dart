import 'package:flutter/material.dart';

import 'SplashScreen.dart';
import 'services/theme_service.dart';
import 'services/sound_service.dart';

class ThemePickerScreen extends StatefulWidget {
  const ThemePickerScreen({super.key});

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen> {
  @override
  void initState() {
    super.initState();
    SoundService.instance.playChime();
    SoundService.instance.startAmbient();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: ThemeService.instance.current,
      builder: (context, activeTheme, _) {
        return Scaffold(
          backgroundColor: activeTheme.background,
          appBar: AppBar(
            backgroundColor: activeTheme.headerBackground,
            foregroundColor: Colors.white,
            elevation: 10,
            title: const Text(
              "Choose a Theme",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          body: Stack(
            children: [
              const DotBackground(),
              ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: ThemeService.all.length,
                itemBuilder: (context, index) {
                  final theme = ThemeService.all[index];
                  final selected = theme.id == activeTheme.id;

                  return GestureDetector(
                    onTap: () {
                      SoundService.instance.playClick();
                      ThemeService.instance.setTheme(theme);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.headerBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? theme.secondaryAccent
                              : Colors.white.withOpacity(0.12),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: theme.secondaryAccent.withOpacity(0.35),
                                  blurRadius: 14,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          // Swatch preview
                          Column(
                            children: [
                              Row(
                                children: [
                                  _swatch(theme.background),
                                  _swatch(theme.accent),
                                  _swatch(theme.secondaryAccent),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  theme.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  theme.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: selected
                                ? theme.secondaryAccent
                                : Colors.white24,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 22,
      height: 34,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}
