import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/ui/explorer/dnd_ready_provider.dart';

void main() {
  test('起動直後は false（DnD 未登録）', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dndReadyProvider), isFalse);
  });

  test('markReady で true になる（ADR-0049）', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(dndReadyProvider.notifier).markReady();

    expect(container.read(dndReadyProvider), isTrue);
  });

  test('markReady は冪等（true のまま）', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(dndReadyProvider.notifier)
      ..markReady()
      ..markReady();

    expect(notifier.state, isTrue);
    expect(container.read(dndReadyProvider), isTrue);
  });
}
