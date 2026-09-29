import 'package:flutter_test/flutter_test.dart';
import 'package:roola/ui/activity_dashboard/meter_physics.dart';

/// [seconds] 秒ぶん 60fps でばねを進め、途中の最大位置も返す。
({SpringState state, double maxPosition}) _runSpring(
  double target,
  double seconds,
) {
  var s = const SpringState();
  var maxPos = 0.0;
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    s = springStep(s, target, 1 / 60);
    if (s.position > maxPos) {
      maxPos = s.position;
    }
  }
  return (state: s, maxPosition: maxPos);
}

void main() {
  group('springStep', () {
    test('目標値に収束する', () {
      final r = _runSpring(0.6, 2);
      expect(r.state.position, closeTo(0.6, 1e-3));
    });

    test('わずかに行き過ぎて戻る（オーバーシュートは 10% 未満）', () {
      final r = _runSpring(0.6, 2);
      expect(r.maxPosition, greaterThan(0.6));
      expect(r.maxPosition, lessThan(0.66));
    });

    test('巨大な dt でも発散しない', () {
      final s = springStep(const SpringState(), 1, 10);
      expect(s.position.isFinite, isTrue);
      expect(s.position, lessThan(1.5));
    });
  });

  group('levelStep', () {
    test('上昇はほぼ即応する', () {
      var level = 0.0;
      for (var i = 0; i < 12; i++) {
        level = levelStep(level, 0.8, 1 / 60);
      }
      expect(level, greaterThan(0.75));
    });

    test('下降は毎秒 60% ぶんの一定速度', () {
      final level = levelStep(0.9, 0, 0.5);
      expect(level, closeTo(0.6, 1e-9));
    });
  });

  group('peakStep', () {
    test('ピークを 1.5 秒保持してから落とす', () {
      var p = peakStep(0, 0, 0.9, 1 / 60);
      expect(p.peak, 0.9);
      p = peakStep(p.peak, p.holdLeft, 0.2, 1.4);
      expect(p.peak, 0.9);
      p = peakStep(p.peak, p.holdLeft, 0.2, 0.05);
      expect(p.peak, 0.9);
      p = peakStep(p.peak, p.holdLeft, 0.2, 1);
      expect(p.peak, closeTo(0.55, 1e-9));
    });

    test('現在値より下には落ちない', () {
      final p = peakStep(0.5, 0, 0.45, 10);
      expect(p.peak, 0.45);
    });
  });

  test('logScale は 1KB/s を 0、1GB/s を 1 に写す', () {
    expect(logScale(1000), closeTo(0, 1e-9));
    expect(logScale(1e9), closeTo(1, 1e-9));
    expect(logScale(1e6), closeTo(0.5, 1e-9));
    expect(logScale(0), 0);
  });
}
