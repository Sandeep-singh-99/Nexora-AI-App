import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_ai_app/app/theme/app_theme.dart';
import 'package:nexora_ai_app/presentation/widgets/app_button.dart';
import 'package:nexora_ai_app/presentation/widgets/app_text_field.dart';
import 'package:nexora_ai_app/presentation/widgets/glass_container.dart';

void main() {
  group('AppTheme & AppColors Tests', () {
    test('lightTheme has Brightness.light and AppColors.light extension', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      final colors = theme.extension<AppColors>();
      expect(colors, isNotNull);
      expect(colors!.brightness, Brightness.light);
      expect(colors.background, const Color(0xFFF9FAFB));
      expect(colors.textPrimary, const Color(0xFF0F172A));
      expect(colors.primary, const Color(0xFF0F172A));
      expect(colors.onPrimary, const Color(0xFFFFFFFF));
    });

    test('darkTheme has Brightness.dark and AppColors.dark extension', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      final colors = theme.extension<AppColors>();
      expect(colors, isNotNull);
      expect(colors!.brightness, Brightness.dark);
      expect(colors.background, const Color(0xFF0E1116));
      expect(colors.textPrimary, const Color(0xFFF8FAFC));
      expect(colors.primary, const Color(0xFFF8FAFC));
      expect(colors.onPrimary, const Color(0xFF0E1116));
    });

    testWidgets('Widgets adapt colors dynamically in Light Theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final c = context.colors;
                expect(c.brightness, Brightness.light);
                return Column(
                  children: [
                    GlassContainer(
                      child: Text('Card', style: TextStyle(color: c.textPrimary)),
                    ),
                    AppButton(text: 'Primary Button', onPressed: () {}),
                    const AppTextField(labelText: 'Email', hintText: 'Enter email'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('Widgets adapt colors dynamically in Dark Theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final c = context.colors;
                expect(c.brightness, Brightness.dark);
                return Column(
                  children: [
                    GlassContainer(
                      child: Text('Card', style: TextStyle(color: c.textPrimary)),
                    ),
                    AppButton(text: 'Dark Primary', onPressed: () {}),
                    const AppTextField(labelText: 'Username', hintText: 'Enter username'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Dark Primary'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });
  });
}
