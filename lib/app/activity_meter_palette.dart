import 'package:flutter/material.dart';

/// アクティビティタブのメーター専用パレット（ADR-0067 / ADR-0068）。
///
/// このタブのメーター描画領域に限り Polaris の単一アクセント規定を適用しない
/// （ADR-0068）。多色の計器色はここに集約し、コンポーネントへ直書きしない。
/// **アクティビティタブ外から参照しないこと。**
@immutable
class ActivityMeterPalette extends ThemeExtension<ActivityMeterPalette> {
  const ActivityMeterPalette({
    required this.ledSafe,
    required this.ledCaution,
    required this.ledPeak,
    required this.readout,
    required this.vfd,
    required this.vfdRed,
    required this.redZone,
    required this.redZoneText,
    required this.needle,
    required this.face,
    required this.faceRing,
    required this.faceHairline,
    required this.tickMajor,
    required this.tickMinor,
    required this.scaleText,
    required this.labelText,
    required this.dimText,
    required this.stage,
    required this.meterWell,
    required this.meterWellEdge,
    required this.raceFill,
    required this.raceUnlit,
    required this.raceCaution,
    required this.raceCautionUnlit,
    required this.raceRedUnlit,
    required this.raceTrim,
    required this.raceTrimCap,
    required this.raceBadge,
    required this.raceBarTrack,
  });

  /// 既定のパレット（モックで合意した配色）。
  static const ActivityMeterPalette standard = ActivityMeterPalette(
    ledSafe: Color(0xFF35E06A),
    ledCaution: Color(0xFFFFC21A),
    ledPeak: Color(0xFFFF3B30),
    readout: Color(0xFFFFB000),
    vfd: Color(0xFFFF8A1F),
    vfdRed: Color(0xFFFF3A1A),
    redZone: Color(0xFFE0261C),
    redZoneText: Color(0xFFFF4A38),
    needle: Color(0xFFFF3D17),
    face: Color(0xFF0A0B0D),
    faceRing: Color(0xFF3A3E45),
    faceHairline: Color(0xFF1A1C20),
    tickMajor: Color(0xFFF4F5F7),
    tickMinor: Color(0xFF9AA0AA),
    scaleText: Color(0xFF6B707A),
    labelText: Color(0xFF8D929C),
    dimText: Color(0xFF5B606A),
    stage: Color(0xFF08090B),
    meterWell: Color(0xFF0B0C0F),
    meterWellEdge: Color(0xFF1E2026),
    raceFill: Color(0xFFD6D9DE),
    raceUnlit: Color(0xFF1D1F23),
    raceCaution: Color(0xFFF28A22),
    raceCautionUnlit: Color(0xFF2C1C10),
    raceRedUnlit: Color(0xFF341511),
    raceTrim: Color(0xFF8A8F98),
    raceTrimCap: Color(0xFFB8BCC3),
    raceBadge: Color(0xFFD8231A),
    raceBarTrack: Color(0xFF2A2C31),
  );

  /// レベルゲージの 3 帯（70% 未満 / 90% 未満 / それ以上）。
  final Color ledSafe;
  final Color ledCaution;
  final Color ledPeak;

  /// 数値表示（琥珀）。
  final Color readout;

  /// DIGITAL（蛍光表示管）のオレンジと、レッドゾーン内の赤橙。
  final Color vfd;
  final Color vfdRed;

  /// CLASSIC のレッドゾーン線 / 数字。
  final Color redZone;
  final Color redZoneText;

  /// CLASSIC の針。
  final Color needle;

  /// 文字盤（フラットな黒）と外周リング・内側ヘアライン。
  final Color face;
  final Color faceRing;
  final Color faceHairline;

  /// 目盛り（長 / 短）。
  final Color tickMajor;
  final Color tickMinor;

  /// 目盛り数字（LEVEL）・ラベル・最弱テキスト。
  final Color scaleText;
  final Color labelText;
  final Color dimText;

  /// メーターを置く舞台の地と、LEVEL のメーター枠。
  final Color stage;
  final Color meterWell;
  final Color meterWellEdge;

  /// RACE: バーグラフ（白 / 橙 / 赤）の点灯・消灯色。
  final Color raceFill;
  final Color raceUnlit;
  final Color raceCaution;
  final Color raceCautionUnlit;
  final Color raceRedUnlit;

  /// RACE: 円の縁取りと水平線、端の丸、バッジ、横バーの地。
  final Color raceTrim;
  final Color raceTrimCap;
  final Color raceBadge;
  final Color raceBarTrack;

  /// テーマから取得する。未登録（テスト等）なら [standard]。
  static ActivityMeterPalette of(BuildContext context) =>
      Theme.of(context).extension<ActivityMeterPalette>() ?? standard;

  /// 0–1 の位置に対応するレベルゲージの帯色。
  Color ledZone(double fraction) => fraction < 0.7
      ? ledSafe
      : fraction < 0.9
      ? ledCaution
      : ledPeak;

  @override
  ActivityMeterPalette copyWith() => this;

  @override
  ActivityMeterPalette lerp(
    ThemeExtension<ActivityMeterPalette>? other,
    double t,
  ) => this;
}
