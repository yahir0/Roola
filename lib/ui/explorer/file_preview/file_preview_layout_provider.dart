import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_preview_layout_provider.g.dart';

/// Explorer タブごとのプレビューパネルの可視状態 + split 比率
/// （ADR-0046 / Decision 7）。
///
/// 永続化しない。アプリ再起動で既定（表示 ON / ratio 0.6）に戻る。
@immutable
class FilePreviewLayout {
  const FilePreviewLayout({required this.visible, required this.ratio});

  /// パネルを描画するか。false ならディレクトリ一覧がタブ body 全幅を占める。
  final bool visible;

  /// 左ペイン（ディレクトリ一覧）が占める比率（0 < ratio < 1）。
  /// `ratio = 0.6` なら一覧 60% / プレビュー 40%。
  final double ratio;

  /// 既定の状態（表示 ON / 6:4）。
  static const FilePreviewLayout initial = FilePreviewLayout(
    visible: true,
    ratio: 0.6,
  );

  /// 最小・最大の split 比率。最小幅相当（listing 240px / preview 280px）の
  /// 確保は描画側で行うが、ratio の極端値はここで丸める。
  static const double minRatio = 0.25;
  static const double maxRatio = 0.85;

  FilePreviewLayout copyWith({bool? visible, double? ratio}) =>
      FilePreviewLayout(
        visible: visible ?? this.visible,
        ratio: ratio ?? this.ratio,
      );

  @override
  bool operator ==(Object other) =>
      other is FilePreviewLayout &&
      other.visible == visible &&
      other.ratio == ratio;

  @override
  int get hashCode => Object.hash(visible, ratio);
}

/// Explorer タブごとに [FilePreviewLayout] を保持する Notifier。
@riverpod
class FilePreviewLayoutNotifier extends _$FilePreviewLayoutNotifier {
  @override
  FilePreviewLayout build(String tabId) => FilePreviewLayout.initial;

  /// 可視状態をトグルする（pane header の表示切替ボタンが呼ぶ）。
  void toggleVisible() => state = state.copyWith(visible: !state.visible);

  /// split 比率を更新する。最小・最大で丸める。
  void setRatio(double ratio) {
    final clamped = ratio.clamp(
      FilePreviewLayout.minRatio,
      FilePreviewLayout.maxRatio,
    );
    if (clamped == state.ratio) return;
    state = state.copyWith(ratio: clamped);
  }
}
