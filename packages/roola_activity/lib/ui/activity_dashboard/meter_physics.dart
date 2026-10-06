import 'dart:math' as math;

/// メーターの動きを作る純粋関数群（ADR-0067 / design D5）。
///
/// ViewModel は 250ms ごとの目標値だけを出し、毎フレームの表示値はここで
/// 補間する。値はすべて 0–1 に正規化したメーター位置。

/// 針・円弧の状態（位置と速度）。
class SpringState {
  const SpringState({this.position = 0, this.velocity = 0});

  final double position;
  final double velocity;
}

/// 針の剛性。モックで調整した値（少しだけ行き過ぎて戻る）。
const double springStiffness = 90;

/// 減衰比。1 未満でわずかにオーバーシュートする。
const double springDampingRatio = 0.7;

/// 積分の刻み幅。フレーム落ちで dt が伸びても発散しないよう細かく刻む。
const double _springStep = 1 / 240;

/// 1 フレームで積分する最大時間。タブ復帰直後などの巨大な dt を抑える。
const double _maxFrameDt = 0.05;

/// ばね＋ダンパで [target] へ追従させる。
SpringState springStep(SpringState state, double target, double dt) {
  final damping = 2 * math.sqrt(springStiffness) * springDampingRatio;
  var x = state.position;
  var v = state.velocity;
  var remaining = math.min(dt, _maxFrameDt);
  while (remaining > 0) {
    final h = math.min(remaining, _springStep);
    final a = springStiffness * (target - x) - damping * v;
    v += a * h;
    x += v * h;
    remaining -= h;
  }
  return SpringState(position: x, velocity: v);
}

/// レベルゲージ 1 チャンネルの状態（表示値・ピーク位置・ピーク保持の残り時間）。
class LevelState {
  const LevelState({this.level = 0, this.peak = 0, this.peakHoldLeft = 0});

  final double level;
  final double peak;
  final double peakHoldLeft;
}

/// 上昇の時定数（秒）。ほぼ即応。
const double levelAttackSeconds = 0.05;

/// 下降速度（フルスケール / 秒）。PPM 風にゆっくり落ちる。
const double levelReleasePerSecond = 0.6;

/// ピークを保持する時間（秒）。
const double peakHoldSeconds = 1.5;

/// 保持後のピーク落下速度（フルスケール / 秒）。
const double peakFallPerSecond = 0.35;

/// PPM 風バリスティクス: 上昇は指数追従、下降は一定速度。
double levelStep(double level, double target, double dt) {
  if (target > level) {
    return level + (target - level) * (1 - math.exp(-dt / levelAttackSeconds));
  }
  return math.max(target, level - levelReleasePerSecond * dt);
}

/// ピークホールド: 現在値が超えたら更新して保持時間をリセット、保持が切れたら
/// 一定速度で落とす（現在値より下には落ちない）。
({double peak, double holdLeft}) peakStep(
  double peak,
  double holdLeft,
  double value,
  double dt,
) {
  if (value >= peak) {
    return (peak: value, holdLeft: peakHoldSeconds);
  }
  final left = holdLeft - dt;
  if (left > 0) {
    return (peak: peak, holdLeft: left);
  }
  return (peak: math.max(value, peak - peakFallPerSecond * dt), holdLeft: 0);
}

/// レベルゲージ 1 チャンネルを 1 フレーム進める。
LevelState levelChannelStep(LevelState state, double target, double dt) {
  final level = levelStep(state.level, target, dt);
  final p = peakStep(state.peak, state.peakHoldLeft, level, dt);
  return LevelState(level: level, peak: p.peak, peakHoldLeft: p.holdLeft);
}

/// オープニング演出の長さ（秒）。この間は目標値をフルスケールにする。
const double openingSweepSeconds = 0.55;

/// I/O の対数目盛りの下限・上限（1 KB/s〜1 GB/s）。
const double _logMin = 3;
const double _logMax = 9;

/// B/s を 0–1 の対数目盛り位置へ変換する。
double logScale(double bytesPerSecond) {
  final l = math.log(math.max(bytesPerSecond, 1)) / math.ln10;
  return ((l - _logMin) / (_logMax - _logMin)).clamp(0.0, 1.0);
}
