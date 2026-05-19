import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roola/data/appearance/polaris_accent.dart';

part 'appearance_settings.freezed.dart';

/// アプリ背景のモード。
///
/// Polaris（ADR-0038）はダーク専用・グラファイト筐体を持つ視覚システムで、
/// 任意色・画像への背景差し替えは思想と相反する。そのため外観モードは
/// 「不透明な筐体」と「筐体を透かす」の 2 択に絞る（旧 solid / image /
/// gradient は廃止）。
///
/// - `opaque`: Polaris のグラファイト筐体をそのまま不透明で描画する（既定）
/// - `transparent`: 筐体全体を `transparencyOpacity` の濃さで半透明に合成し、
///   背後のデスクトップを透かす
enum AppearanceMode { opaque, transparent }

/// アプリ全体の外観設定。
///
/// `mode` によって描画が分岐する。詳細は [AppearanceMode] の dartdoc を参照。
@freezed
abstract class AppearanceSettings with _$AppearanceSettings {
  const factory AppearanceSettings({
    @Default(AppearanceMode.opaque) AppearanceMode mode,

    /// `transparent` モードで筐体を合成する不透明度（0.0〜1.0）。
    /// 1.0 で完全不透明、0.0 で完全透過。
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

  /// 既定値（不透明な Polaris グラファイト筐体）。
  factory AppearanceSettings.defaults() => const AppearanceSettings();
}
