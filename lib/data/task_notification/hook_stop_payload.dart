import 'dart:convert';

/// Stop フックが受信口へ POST する JSON のパース結果（ADR-0057）。
///
/// `tab_id` / `token` は Roola が PTY に注入した環境変数由来で必須。
/// `session_id` / `cwd` はフック stdin の JSON 由来で、表示やデデュープに使う
/// 補助情報（欠けていても通知判定は可能）。
class HookStopPayload {
  const HookStopPayload({
    required this.tabId,
    required this.token,
    this.sessionId,
    this.cwd,
  });

  final String tabId;
  final String token;
  final String? sessionId;
  final String? cwd;

  /// JSON 文字列をパースする。`tab_id` / `token` が非空文字列で揃わない場合は
  /// `null`（不正リクエストとして無視させる）。
  static HookStopPayload? tryParse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final tabId = decoded['tab_id'];
    final token = decoded['token'];
    if (tabId is! String || tabId.isEmpty) {
      return null;
    }
    if (token is! String || token.isEmpty) {
      return null;
    }
    final sessionId = decoded['session_id'];
    final cwd = decoded['cwd'];
    return HookStopPayload(
      tabId: tabId,
      token: token,
      sessionId: sessionId is String && sessionId.isNotEmpty ? sessionId : null,
      cwd: cwd is String && cwd.isNotEmpty ? cwd : null,
    );
  }
}
