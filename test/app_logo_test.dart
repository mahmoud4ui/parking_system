import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo draws at the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: AppLogo(size: 60))),
    );

    expect(tester.getSize(find.byType(AppLogo)), const Size(60, 60));
  });
}
