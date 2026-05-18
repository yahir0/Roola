import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roola/data/notepad/notepad_repository.dart';
import 'package:roola/data/notepad/notepad_repository_impl.dart';
import 'package:roola/ui/notepad/notepad_view_model.dart';

class _MockNotepadRepository extends Mock implements NotepadRepository {}

void main() {
  late _MockNotepadRepository repository;

  setUp(() {
    repository = _MockNotepadRepository();
    when(() => repository.save(any())).thenAnswer((_) async {});
  });

  ProviderContainer buildContainer({String initial = ''}) {
    return ProviderContainer(
      overrides: [
        notepadRepositoryProvider.overrideWithValue(repository),
        notepadInitialContentProvider.overrideWithValue(initial),
      ],
    );
  }

  /// 後始末を tearDown に登録した [ProviderContainer] を作る。
  ProviderContainer makeContainer({String initial = ''}) {
    final container = buildContainer(initial: initial);
    addTearDown(container.dispose);
    return container;
  }

  /// debounce が確実に満了するまで待つ。
  Future<void> waitForDebounce() => Future<void>.delayed(
    NotepadViewModel.saveDebounce + const Duration(milliseconds: 100),
  );

  test('build exposes the injected initial content', () {
    final container = makeContainer(initial: 'seed');
    expect(container.read(notepadProvider), 'seed');
  });

  test('updateContent reflects new content immediately', () {
    final container = makeContainer();
    container.read(notepadProvider.notifier).updateContent('typed');
    expect(container.read(notepadProvider), 'typed');
  });

  test('updateContent persists after the debounce window', () async {
    final container = makeContainer();
    container.read(notepadProvider.notifier).updateContent('typed');
    verifyNever(() => repository.save(any()));

    await waitForDebounce();
    verify(() => repository.save('typed')).called(1);
  });

  test('rapid edits coalesce into a single persisted save', () async {
    final container = makeContainer();
    final notifier = container.read(notepadProvider.notifier);
    notifier.updateContent('a');
    notifier.updateContent('ab');
    notifier.updateContent('abc');

    await waitForDebounce();
    verify(() => repository.save('abc')).called(1);
  });

  test('an unchanged update schedules no save', () async {
    final container = makeContainer(initial: 'same');
    container.read(notepadProvider.notifier).updateContent('same');

    await waitForDebounce();
    verifyNever(() => repository.save(any()));
  });

  test('disposing the provider flushes pending unsaved content', () {
    final container = buildContainer();
    container.read(notepadProvider.notifier).updateContent('unsaved');
    container.dispose();

    verify(() => repository.save('unsaved')).called(1);
  });
}
