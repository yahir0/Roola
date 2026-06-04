import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:roola/data/cc_usage/cc_usage.dart';
import 'package:roola/data/cc_usage/cc_usage_pricing.dart';

/// Claude Code がローカルに書き出す JSONL を集計して使用量を返す
/// リポジトリ（ADR-0060）。
///
/// データソースは `~/.claude/projects/**/*.jsonl` のみ。ネットワークや
/// Claude Code 本体プロセスには依存しない（自己完結方針 ADR-0005）。
/// 当日（ローカルタイム）の `message.usage` を持つ assistant 行を集計し、
/// `message.id` + `requestId` で重複を排除して推定コストを算定する。
class CcUsageRepository {
  /// [now] と [homeDirectory] はテスト用の差し替え口。
  CcUsageRepository({
    DateTime Function()? now,
    String? Function()? homeDirectory,
  }) : _now = now ?? DateTime.now,
       _homeDirectory = homeDirectory ?? _defaultHomeDirectory;

  final DateTime Function() _now;
  final String? Function() _homeDirectory;

  /// 監視対象でもある Claude Code の projects ディレクトリ。存在しない環境
  /// （`~/.claude` 不在等）では null を返す。
  Directory? projectsDirectory() {
    final home = _homeDirectory();
    if (home == null || home.isEmpty) return null;
    return Directory(p.join(home, '.claude', 'projects'));
  }

  /// 当日（ローカルタイムの 0:00〜現在）の使用量を集計する。
  ///
  /// projects ディレクトリが無い場合は [CcUsage.zero] を返す（エラーにしない）。
  /// 破損行・`usage` を持たない行はスキップし、ファイル全体の集計は継続する。
  Future<CcUsage> aggregateToday() async {
    final dir = projectsDirectory();
    if (dir == null || !dir.existsSync()) return CcUsage.zero;

    final now = _now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final seen = <String>{};
    var inputTokens = 0;
    var outputTokens = 0;
    var cacheReadTokens = 0;
    var cacheCreationTokens = 0;
    var cost = 0.0;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.jsonl')) continue;

      // 当日分の行は当日に追記されたファイルにしか存在しないため、最終更新が
      // 当日より前のファイルは丸ごとスキップする（全走査の負荷を避ける）。
      try {
        if (entity.statSync().modified.isBefore(startOfToday)) continue;
      } on FileSystemException {
        continue;
      }

      final List<String> lines;
      try {
        lines = await entity.readAsLines();
      } on FileSystemException {
        continue;
      }

      for (final line in lines) {
        if (line.isEmpty) continue;
        final record = _parseUsageLine(line, startOfToday);
        if (record == null) continue;
        if (!seen.add(record.dedupKey)) continue;

        inputTokens += record.inputTokens;
        outputTokens += record.outputTokens;
        cacheReadTokens += record.cacheReadTokens;
        cacheCreationTokens += record.cacheCreationTokens;
        cost +=
            pricingForModel(record.model)?.cost(
              inputTokens: record.inputTokens,
              outputTokens: record.outputTokens,
              cacheReadTokens: record.cacheReadTokens,
              cacheCreationTokens: record.cacheCreationTokens,
            ) ??
            0;
      }
    }

    return CcUsage(
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      cacheReadTokens: cacheReadTokens,
      cacheCreationTokens: cacheCreationTokens,
      estimatedCostUsd: cost,
    );
  }

  /// JSONL の 1 行を解析し、当日の集計対象なら [_UsageRecord] を返す。
  /// 集計対象外（破損・usage 無し・当日外・キー欠落）は null。
  _UsageRecord? _parseUsageLine(String line, DateTime startOfToday) {
    final Object? decoded;
    try {
      decoded = jsonDecode(line);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, Object?>) return null;
    if (decoded['type'] != 'assistant') return null;

    final message = decoded['message'];
    if (message is! Map<String, Object?>) return null;
    final usage = message['usage'];
    if (usage is! Map<String, Object?>) return null;

    final timestamp = decoded['timestamp'];
    if (timestamp is! String) return null;
    final parsed = DateTime.tryParse(timestamp);
    if (parsed == null) return null;
    if (parsed.toLocal().isBefore(startOfToday)) return null;

    final messageId = message['id'];
    final requestId = decoded['requestId'];
    if (messageId is! String || requestId is! String) return null;

    return _UsageRecord(
      dedupKey: '$messageId::$requestId',
      model: message['model'] is String ? message['model']! as String : null,
      inputTokens: _asInt(usage['input_tokens']),
      outputTokens: _asInt(usage['output_tokens']),
      cacheReadTokens: _asInt(usage['cache_read_input_tokens']),
      cacheCreationTokens: _asInt(usage['cache_creation_input_tokens']),
    );
  }

  static int _asInt(Object? value) => value is int ? value : 0;

  static String? _defaultHomeDirectory() =>
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
}

/// 集計対象の 1 行分を表す内部レコード。
class _UsageRecord {
  const _UsageRecord({
    required this.dedupKey,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
    required this.cacheReadTokens,
    required this.cacheCreationTokens,
  });

  final String dedupKey;
  final String? model;
  final int inputTokens;
  final int outputTokens;
  final int cacheReadTokens;
  final int cacheCreationTokens;
}

/// 使用量集計リポジトリの Provider。
final ccUsageRepositoryProvider = Provider<CcUsageRepository>(
  (ref) => CcUsageRepository(),
);
