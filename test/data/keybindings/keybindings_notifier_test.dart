import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roola/data/keybindings/command_id.dart';
import 'package:roola/data/keybindings/command_registry.dart';
import 'package:roola/data/keybindings/effective_keybindings.dart';
import 'package:roola/data/keybindings/key_chord.dart';
import 'package:roola/data/keybindings/keybindings.dart';
import 'package:roola/data/keybindings/keybindings_repository.dart';
import 'package:roola/data/keybindings/keybindings_repository_impl.dart';

class _MockRepo extends Mock implements KeybindingsRepository {}

KeyChord _chord(LogicalKeyboardKey key) =>
    KeyChord(triggerKeyId: key.keyId, meta: true, alt: true);

void main() {
  late _MockRepo repo;

  setUpAll(() => registerFallbackValue(Keybindings.empty()));

  setUp(() {
    repo = _MockRepo();
    when(() => repo.load()).thenAnswer((_) async => Keybindings.empty());
    when(() => repo.save(any())).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [keybindingsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('setChord で上書きが入り保存される', () async {
    final container = makeContainer();
    await container.read(keybindingsProvider.future);
    final chord = _chord(LogicalKeyboardKey.keyZ);

    await container
        .read(keybindingsProvider.notifier)
        .setChord(CommandId.copyPath, chord);

    expect(
      container.read(keybindingsProvider).value!.overrides[CommandId.copyPath],
      chord,
    );
    verify(() => repo.save(any())).called(1);
  });

  test('resetToDefault で上書きが消える', () async {
    final container = makeContainer();
    await container.read(keybindingsProvider.future);
    final notifier = container.read(keybindingsProvider.notifier);

    await notifier.setChord(
      CommandId.copyPath,
      _chord(LogicalKeyboardKey.keyZ),
    );
    await notifier.resetToDefault(CommandId.copyPath);

    expect(
      container
          .read(keybindingsProvider)
          .value!
          .overrides
          .containsKey(CommandId.copyPath),
      isFalse,
    );
  });

  test('resetAll で全上書きが消える', () async {
    final container = makeContainer();
    await container.read(keybindingsProvider.future);
    final notifier = container.read(keybindingsProvider.notifier);

    await notifier.setChord(
      CommandId.copyPath,
      _chord(LogicalKeyboardKey.keyZ),
    );
    await notifier.setChord(
      CommandId.closeTab,
      _chord(LogicalKeyboardKey.keyX),
    );
    await notifier.resetAll();

    expect(container.read(keybindingsProvider).value!.overrides, isEmpty);
  });

  group('effectiveKeybindingsProvider', () {
    test('上書きが無ければ全コマンドが既定キーコンビ', () async {
      final container = makeContainer();
      await container.read(keybindingsProvider.future);

      final effective = container.read(effectiveKeybindingsProvider);
      expect(effective.length, CommandId.values.length);
      for (final id in CommandId.values) {
        expect(effective[id], CommandRegistry.metadataFor(id).defaultChord);
      }
    });

    test('上書きと既定をマージする', () async {
      final container = makeContainer();
      await container.read(keybindingsProvider.future);
      final chord = _chord(LogicalKeyboardKey.keyZ);

      await container
          .read(keybindingsProvider.notifier)
          .setChord(CommandId.copyPath, chord);

      final effective = container.read(effectiveKeybindingsProvider);
      expect(effective[CommandId.copyPath], chord);
      expect(
        effective[CommandId.closeTab],
        CommandRegistry.metadataFor(CommandId.closeTab).defaultChord,
      );
    });
  });
}
