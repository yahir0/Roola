import 'package:freezed_annotation/freezed_annotation.dart';

part 'appearance_settings.freezed.dart';

/// アプリ背景のモード。
///
/// - `transparent`: 背景は描画しない（OS の透過レイヤーが見える）
/// - `solid`: `solidColor` で塗りつぶす
/// - `image`: `imagePath` の画像を画面いっぱいにカバー表示する
/// - `gradient`: ロゴ由来の gunmetal グラデーション（`LogoTheme.backgroundGradient`）
///   を画面いっぱいに描画する。色は固定で追加フィールドは不要
enum AppearanceMode { transparent, solid, image, gradient }

/// アプリ全体の外観設定。
///
/// `mode` によって描画が分岐する。詳細は [AppearanceMode] の dartdoc を参照。
@freezed
abstract class AppearanceSettings with _$AppearanceSettings {
  const factory AppearanceSettings({
    @Default(AppearanceMode.transparent) AppearanceMode mode,

    /// RGBA を 32bit int で保持（`Color.toARGB32()` 相当）。
    int? solidColor,
    String? imagePath,

    /// `transparent` モードで背景にうっすら載せる暗幕の不透明度（0.0〜1.0）。
    /// 1.0 で完全不透明、0.0 で完全透過。色はロゴの deep background 固定。
    /// 既定値はウィンドウ枠が視認できる程度の 0.8。
    @Default(0.8) double transparencyOpacity,
  }) = _AppearanceSettings;

  /// 既定値（透過 + 不透明度 0.8）。
  factory AppearanceSettings.defaults() => const AppearanceSettings();
}
