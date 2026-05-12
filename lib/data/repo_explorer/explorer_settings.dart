import 'package:freezed_annotation/freezed_annotation.dart';

part 'explorer_settings.freezed.dart';

/// エクスプローラ画面の永続化対象状態。
///
/// 現在は「最後に開いたルートパス」だけを持つ。将来、複数ブックマークや
/// 並び順設定を追加する場合もここに足す。
@freezed
abstract class ExplorerSettings with _$ExplorerSettings {
  const factory ExplorerSettings({
    /// 最後に開いていたルートディレクトリの絶対パス。`null` なら未設定
    /// （ホームディレクトリで開く）。
    String? rootPath,
  }) = _ExplorerSettings;

  /// 既定値（未設定）。
  factory ExplorerSettings.defaults() => const ExplorerSettings();
}
