import 'package:freezed_annotation/freezed_annotation.dart';

part 'appearance_settings.freezed.dart';

/// アプリ背景のモード。
enum AppearanceMode { transparent, solid, image }

/// アプリ全体の外観設定。
///
/// `mode` によって描画が分岐する:
/// - `transparent`: 背景は描画しない（OS の透過レイヤーが見える）
/// - `solid`: `solidColor` で塗りつぶす
/// - `image`: `imagePath` の画像を画面いっぱいにカバー表示する
@freezed
abstract class AppearanceSettings with _$AppearanceSettings {
  const factory AppearanceSettings({
    @Default(AppearanceMode.transparent) AppearanceMode mode,

    /// RGBA を 32bit int で保持（`Color.toARGB32()` 相当）。
    int? solidColor,
    String? imagePath,
  }) = _AppearanceSettings;

  /// 既定値（透過）。
  factory AppearanceSettings.defaults() => const AppearanceSettings();
}
