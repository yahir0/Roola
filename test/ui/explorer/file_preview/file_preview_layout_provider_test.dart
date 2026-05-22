import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/ui/explorer/file_preview/file_preview_layout_provider.dart';

void main() {
  test('既定はプレビュー非表示（ADR-0050）', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final layout = container.read(filePreviewLayoutProvider('tab-1'));

    expect(layout.visible, isFalse);
    expect(layout.ratio, 0.6);
  });

  test('toggleVisible で表示 ↔ 非表示が切り替わる', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      filePreviewLayoutProvider('tab-1').notifier,
    );
    notifier.toggleVisible();

    expect(container.read(filePreviewLayoutProvider('tab-1')).visible, isTrue);

    notifier.toggleVisible();

    expect(container.read(filePreviewLayoutProvider('tab-1')).visible, isFalse);
  });

  test('setVisible は明示的に可視状態を設定する（ADR-0050）', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      filePreviewLayoutProvider('tab-1').notifier,
    );

    notifier.setVisible(visible: true);
    expect(container.read(filePreviewLayoutProvider('tab-1')).visible, isTrue);

    notifier.setVisible(visible: false);
    expect(container.read(filePreviewLayoutProvider('tab-1')).visible, isFalse);
  });

  test('setRatio は min/max で丸める', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      filePreviewLayoutProvider('tab-1').notifier,
    );

    notifier.setRatio(0.05);
    expect(
      container.read(filePreviewLayoutProvider('tab-1')).ratio,
      FilePreviewLayout.minRatio,
    );

    notifier.setRatio(0.99);
    expect(
      container.read(filePreviewLayoutProvider('tab-1')).ratio,
      FilePreviewLayout.maxRatio,
    );
  });
}
