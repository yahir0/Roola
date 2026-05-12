import 'package:claude_skills_launcher/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('HomePage shows empty placeholder when no entries are registered',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomePage()),
      ),
    );

    expect(find.text('Claude Skills Launcher'), findsOneWidget);
    expect(find.text('登録されたランチャーがまだありません'), findsOneWidget);
  });
}
