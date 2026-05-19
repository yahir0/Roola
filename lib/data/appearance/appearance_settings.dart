import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/appearance/polaris_accent.dart';

part 'appearance_settings.freezed.dart';

/// アプリ背景のモード。
///
/// - `transparent`: 背景は描画しない（OS の透過レイヤーが見える）
/// - `solid`: `solidColor` で塗りつぶす
/// - `image`: `imagePath` の画像を画面いっぱいにカバー表示する
/// - `gradient`: Polaris のグラファイトグラデーション（`AppTheme.backgroundGradient`）
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

    /// `transparent` モード時に中央に重ね描きする画像のパス。
    /// 日本国旗の赤円のように「窓の真ん中に配置する装飾」用で、サイズは
    /// ウィンドウの短辺の 60% 程度に縮めて表示する。null なら描画しない。
    String? transparentCenterImagePath,

    /// 中央画像ファイルの更新時刻（`millisecondsSinceEpoch`）。同じパスに
    /// 上書き保存しても state の equality が壊れず Image widget が再
    /// リゾルブされない問題を回避するための「変化のシグナル」として持つ。
    /// path と同時に必ずセットする。null は「画像なし」と等価。
    int? transparentCenterImageMtime,

    /// Polaris のアクセント色（ADR-0038 D4）。既定はゴールド。
    @Default(PolarisAccent.gold) PolarisAccent accent,
  }) = _AppearanceSettings;

  /// 既定値（透過 + 不透明度 0.8）。
  factory AppearanceSettings.defaults() => const AppearanceSettings();
}
