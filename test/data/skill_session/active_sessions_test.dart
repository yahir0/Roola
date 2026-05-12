import 'package:claude_skills_launcher/data/skill_runner/skill_run_state.dart';
import 'package:claude_skills_launcher/data/skill_session/active_sessions.dart';
import 'package:claude_skills_launcher/data/skill_session/adhoc_run_args.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('build returns empty map', () {
    final state = container.read(activeSessionsProvider);
    expect(state, isEmpty);
  });

  test('register adds entry with initial state', () {
    final notifier = container.read(activeSessionsProvider.notifier);
    notifier.register(
      entryId: 'a',
      initialState: const SkillRunState.idle(),
      cancel: () async {},
    );
    final state = container.read(activeSessionsProvider);
    expect(state.keys, ['a']);
    expect(state['a'], isA<SkillRunIdle>());
  });

  test('updateState reflects new state for registered entry', () {
    final notifier = container.read(activeSessionsProvider.notifier);
    notifier.register(
      entryId: 'a',
      initialState: const SkillRunState.starting(),
      cancel: () async {},
    );
    notifier.updateState('a', const SkillRunState.running());
    expect(container.read(activeSessionsProvider)['a'], isA<SkillRunRunning>());
  });

  test('updateState is ignored for unregistered entry', () {
    final notifier = container.read(activeSessionsProvider.notifier);
    notifier.updateState('ghost', const SkillRunState.running());
    expect(container.read(activeSessionsProvider), isEmpty);
  });

  test('unregister removes entry', () {
    final notifier = container.read(activeSessionsProvider.notifier);
    notifier.register(
      entryId: 'a',
      initialState: const SkillRunState.running(),
      cancel: () async {},
    );
    notifier.unregister('a');
    expect(container.read(activeSessionsProvider), isEmpty);
  });

  test('cancelAll invokes every registered cancel handler', () async {
    final calls = <String>[];
    final notifier = container.read(activeSessionsProvider.notifier);
    notifier.register(
      entryId: 'a',
      initialState: const SkillRunState.running(),
      cancel: () async => calls.add('a'),
    );
    notifier.register(
      entryId: 'b',
      initialState: const SkillRunState.running(),
      cancel: () async => calls.add('b'),
    );

    await notifier.cancelAll();
    expect(calls, containsAll(<String>['a', 'b']));
  });

  test('cancelAll on empty registry resolves without error', () async {
    final notifier = container.read(activeSessionsProvider.notifier);
    await notifier.cancelAll();
    expect(container.read(activeSessionsProvider), isEmpty);
  });

  test('unregister drops the cancel handler', () async {
    var called = false;
    final notifier = container.read(activeSessionsProvider.notifier);
    notifier.register(
      entryId: 'a',
      initialState: const SkillRunState.running(),
      cancel: () async => called = true,
    );
    notifier.unregister('a');
    await notifier.cancelAll();
    expect(called, isFalse);
  });

  test('labelFor returns null for non-adhoc / unknown ids', () {
    final notifier = container.read(activeSessionsProvider.notifier);
    notifier.register(
      entryId: 'a',
      initialState: const SkillRunState.running(),
      cancel: () async {},
    );
    expect(notifier.labelFor('a'), isNull);
    expect(notifier.labelFor('ghost'), isNull);
  });

  test(
    'register with adhocArgs populates label/args; unregister clears them',
    () {
      final notifier = container.read(activeSessionsProvider.notifier);
      const args = AdhocRunArgs(
        adhocId: 'adhoc-1',
        repositoryPath: '/Users/foo/repos/demo',
        displayName: 'demo (Claude)',
      );
      notifier.register(
        entryId: 'adhoc-1',
        initialState: const SkillRunState.running(),
        cancel: () async {},
        adhocArgs: args,
      );
      expect(notifier.labelFor('adhoc-1'), 'demo (Claude)');
      expect(notifier.adhocArgsFor('adhoc-1'), args);

      notifier.unregister('adhoc-1');
      expect(notifier.labelFor('adhoc-1'), isNull);
      expect(notifier.adhocArgsFor('adhoc-1'), isNull);
    },
  );

  test('state object identity changes on each mutation (reactive)', () {
    final notifier = container.read(activeSessionsProvider.notifier);
    final s0 = container.read(activeSessionsProvider);
    notifier.register(
      entryId: 'a',
      initialState: const SkillRunState.idle(),
      cancel: () async {},
    );
    final s1 = container.read(activeSessionsProvider);
    notifier.updateState('a', const SkillRunState.running());
    final s2 = container.read(activeSessionsProvider);
    notifier.unregister('a');
    final s3 = container.read(activeSessionsProvider);

    expect(identical(s0, s1), isFalse);
    expect(identical(s1, s2), isFalse);
    expect(identical(s2, s3), isFalse);
  });
}
