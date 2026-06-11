import 'package:freezed_annotation/freezed_annotation.dart';

part 'privacy_settings.freezed.dart';

/// 利用規約への同意状態とアナリティクス送信可否（ADR-0065）。
///
/// 同意（規約バージョン）と送信可否（トグル）は別概念だが、ライフサイクルが
/// 同じ（同意モーダルで両方確定し、設定画面でトグルだけ変更する）ため
/// 1 ファイル（`privacy_settings.json`）にまとめて永続化する。
@freezed
abstract class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    /// ユーザーが同意した利用規約の版数。未同意なら null。
    /// `currentTermsVersion` より古い場合も再同意が必要（規約改定時）。
    int? acceptedTermsVersion,

    /// 匿名利用統計（Aptabase）の送信可否。既定 ON。
    /// 同意モーダルと設定画面のトグルで変更できる。
    @Default(true) bool analyticsEnabled,
  }) = _PrivacySettings;

  /// 既定値（未同意・アナリティクス ON）。
  factory PrivacySettings.defaults() => const PrivacySettings();
}
