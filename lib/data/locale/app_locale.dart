import 'package:flutter/widgets.dart';

/// アプリがサポートする表示言語（ADR-0034）。
///
/// 当面は日本語・英語の 2 言語。既定は日本語。
enum AppLocale {
  ja(Locale('ja')),
  en(Locale('en'));

  const AppLocale(this.locale);

  /// `MaterialApp` に渡す Flutter の [Locale]。
  final Locale locale;

  /// 永続化に使う言語コード（`enum` 名と一致）。
  String get code => name;

  /// 既定の表示言語。
  static const AppLocale defaultLocale = AppLocale.ja;

  /// 永続化された言語コードから復元する。未知・null は既定（日本語）。
  static AppLocale fromCode(String? code) => AppLocale.values.firstWhere(
    (l) => l.code == code,
    orElse: () => defaultLocale,
  );
}
