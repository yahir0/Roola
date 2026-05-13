import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository.dart';
import 'package:claude_skills_launcher/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:claude_skills_launcher/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _FakeLauncherEntryRepository implements LauncherEntryRepository {
  _FakeLauncherEntryRepository(this.initial);

  final List<LauncherEntry> initial;

  @override
  Future<List<LauncherEntry>> loadAll() async => initial;

  @override
  Future<void> add(LauncherEntry entry) async {}

  @override
  Future<void> update(LauncherEntry entry) async {}

  @override
  Future<void> delete(String id) async {}
}

void main() {
  testWidgets(
    'HomePage shows empty placeholder when no entries are registered',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            launcherEntryRepositoryProvider.overrideWith(
              (ref) => _FakeLauncherEntryRepository(const []),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('登録されたランチャーがまだありません'), findsOneWidget);
    },
  );
}
