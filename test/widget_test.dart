import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digi_drobe/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
    // Build the LoginScreen directly to bypass Firebase initialization in MyApp.
    // We use a MediaQuery and Material to provide the necessary context.
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Verify that the login screen title or some unique text is present.
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    
    // Verify that the login button is present.
    expect(find.text('Login'), findsOneWidget);
  });
}
