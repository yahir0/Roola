import 'dart:math' as math;

/// I/O レート（B/s）の表示用ユーティリティ（ADR-0048 D5）。
///
/// - [formatBytesPerSec]: 人間可読単位の文字列を返す。`512 B/s` /
///   `1.2 KB/s` / `12 MB/s` / `1.2 GB/s` のように、桁が上がるごとに表記を
///   切り替える。
/// - [logScaleBytesPerSec]: 対数スケールでバー占有率（0–1）を返す。
///   `< 1 KB/s` は 0、`> 1 GB/s` は 1 にクランプ。1 KB/s → 1 GB/s を
///   `log10` で線形マップする。
class IoRateFormat {
  IoRateFormat._();

  static const double _kib = 1024;
  static const double _mib = 1024 * 1024;
  static const double _gib = 1024 * 1024 * 1024;

  /// 対数スケールの下限（1 KB/s = 0%）。
  static const double logScaleMinBytesPerSec = _kib;

  /// 対数スケールの上限（1 GB/s = 100%）。
  static const double logScaleMaxBytesPerSec = _gib;

  /// I/O レートを人間可読な文字列にする。
  ///
  /// 0 は `0 B/s`、`< 1 KB/s` は整数 B/s、`< 10 KB/s` は小数 1 桁、それ以上は
  /// 整数 1–3 桁にする。`1024^3` 以上は `GB/s`。
  static String formatBytesPerSec(double bytesPerSec) {
    final v = bytesPerSec.isFinite && bytesPerSec > 0 ? bytesPerSec : 0;
    if (v < _kib) {
      return '${v.round()} B/s';
    }
    if (v < _mib) {
      final kb = v / _kib;
      return kb < 10 ? '${kb.toStringAsFixed(1)} KB/s' : '${kb.round()} KB/s';
    }
    if (v < _gib) {
      final mb = v / _mib;
      return mb < 10 ? '${mb.toStringAsFixed(1)} MB/s' : '${mb.round()} MB/s';
    }
    final gb = v / _gib;
    return gb < 10 ? '${gb.toStringAsFixed(1)} GB/s' : '${gb.round()} GB/s';
  }

  /// I/O レートを対数スケールでバー占有率 0–1 にマップする。
  ///
  /// `< 1 KB/s` は 0、`> 1 GB/s` は 1 にクランプし、その間は `log10` で
  /// 線形マップする。`1 KB/s → 1 GB/s` は 6 桁分（`log10(1e6)`）の幅を取る。
  static double logScaleBytesPerSec(double bytesPerSec) {
    if (!bytesPerSec.isFinite || bytesPerSec <= logScaleMinBytesPerSec) {
      return 0;
    }
    if (bytesPerSec >= logScaleMaxBytesPerSec) {
      return 1;
    }
    final num = math.log(bytesPerSec / logScaleMinBytesPerSec);
    final den = math.log(logScaleMaxBytesPerSec / logScaleMinBytesPerSec);
    return num / den;
  }
}
