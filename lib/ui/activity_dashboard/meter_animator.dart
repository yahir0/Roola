import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:roola/ui/activity_dashboard/meter_physics.dart';

/// メーター群の表示値を毎フレーム進めるアニメータ（design D5）。
///
/// ViewModel が 250ms ごとに出す目標値を [setTargets] で受け取り、Ticker から
/// 呼ばれる [tick] で針（ばね＋ダンパ）とレベル（PPM 風＋ピークホールド）を
/// 同時に進める。Painter は `repaint:` にこのアニメータを渡し、ウィジェットの
/// 再ビルドなしで毎フレーム描き直す。全チャンネルが落ち着いたフレームは通知
/// しない（静止中の無駄な再描画を避ける）。
class MeterAnimator extends ChangeNotifier {
  final Map<String, double> _targets = {};
  final Map<String, SpringState> _springs = {};
  final Map<String, LevelState> _levels = {};
  double _sweepLeft = 0;
  bool _dirty = true;

  /// OS のアニメーション低減設定。真なら補間・演出をせず目標値へ即時スナップ。
  bool reduceMotion = false;

  /// 値が落ち着いていても毎フレーム通知する（RACE のシフトライト全灯点滅など、
  /// 時間で見た目が変わる表示の間だけ立てる）。
  bool continuous = false;

  /// 目標値（0–1）を差し替える。キーはチャンネル ID（`cpu` / `core3` 等）。
  void setTargets(Map<String, double> targets) {
    _targets
      ..clear()
      ..addAll(targets);
    _dirty = true;
  }

  /// オープニング演出を始める（一度フルスケールまで振って戻る）。
  void startSweep() {
    if (reduceMotion) {
      return;
    }
    _sweepLeft = openingSweepSeconds;
    _dirty = true;
  }

  /// 1 フレーム進める。[dt] は前フレームからの経過秒。
  void tick(double dt) {
    final sweeping = _sweepLeft > 0;
    _sweepLeft = math.max(0, _sweepLeft - dt);
    var moving = sweeping;
    for (final MapEntry(:key, :value) in _targets.entries) {
      final target = sweeping ? 1.0 : value;
      if (reduceMotion) {
        _springs[key] = SpringState(position: target);
        _levels[key] = LevelState(level: target, peak: target);
        continue;
      }
      final spring = springStep(
        _springs[key] ?? const SpringState(),
        target,
        dt,
      );
      final level = levelChannelStep(
        _levels[key] ?? const LevelState(),
        target,
        dt,
      );
      _springs[key] = spring;
      _levels[key] = level;
      if ((spring.position - target).abs() > 1e-4 ||
          spring.velocity.abs() > 1e-4 ||
          (level.level - target).abs() > 1e-4 ||
          level.peak - level.level > 1e-4) {
        moving = true;
      }
    }
    if (moving || _dirty || continuous) {
      _dirty = false;
      notifyListeners();
    }
  }

  /// 針・円弧の表示位置（0–1 付近。オーバーシュートで僅かに超えうる）。
  double needle(String key) => _springs[key]?.position ?? 0;

  /// レベルゲージの表示値とピーク。
  LevelState level(String key) => _levels[key] ?? const LevelState();
}
