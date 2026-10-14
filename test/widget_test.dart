import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_ai_app/presentation/widgets/app_button.dart';

void main() {
  testWidgets('AppButton renders all variants without assertions', (tester) async {
    for (final variant in ButtonVariant.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              variant: variant,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Test Button'), findsOneWidget);
    }
  });
}
