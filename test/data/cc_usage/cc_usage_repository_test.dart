import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/cc_usage/cc_usage.dart';
import 'package:roola/data/cc_usage/cc_usage_repository.dart';

void main() {
  // 当日判定の基準時刻を固定する（ローカルタイムの 2026-06-04 12:00）。
  final fixedNow = DateTime(2026, 6, 4, 12);

  late Directory tempHome;
  late Directory projectDir;

  setUp(() async {
    tempHome = await Directory.systemTemp.createTemp('roola_ccusage_');
    projectDir = Directory('${tempHome.path}/.claude/projects/proj-a')
      ..createSync(recursive: true);
  });

  tearDown(() async {
    if (tempHome.existsSync()) {
      await tempHome.delete(recursive: true);
    }
  });

  CcUsageRepository repo() => CcUsageRepository(
    now: () => fixedNow,
    homeDirectory: () => tempHome.path,
  );

  /// assistant の usage 行を 1 行ぶん組み立てる。
  String usageLine({
    required String messageId,
    required String requestId,
    required DateTime timestamp,
    String model = 'claude-opus-4-8',
    int input = 0,
    int output = 0,
    int cacheRead = 0,
    int cacheCreation = 0,
  }) {
    return jsonEncode({
      'type': 'assistant',
      'requestId': requestId,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'message': {
        'id': messageId,
        'model': model,
        'usage': {
          'input_tokens': input,
          'output_tokens': output,
          'cache_read_input_tokens': cacheRead,
          'cache_creation_input_tokens': cacheCreation,
        },
      },
    });
  }

  void writeJsonl(String name, List<String> lines) {
    File('${projectDir.path}/$name.jsonl').writeAsStringSync(lines.join('\n'));
  }

  test('当日のトークンを種別ごとに合算する', () async {
    writeJsonl('s1', [
      usageLine(
        messageId: 'm1',
        requestId: 'r1',
        timestamp: fixedNow,
        input: 100,
        output: 20,
        cacheRead: 5,
        cacheCreation: 50,
      ),
      usageLine(
        messageId: 'm2',
        requestId: 'r2',
        timestamp: fixedNow,
        input: 10,
        output: 2,
      ),
    ]);

    final usage = await repo().aggregateToday();

    expect(usage.inputTokens, 110);
    expect(usage.outputTokens, 22);
    expect(usage.cacheReadTokens, 5);
    expect(usage.cacheCreationTokens, 50);
    expect(usage.totalTokens, 187);
    expect(usage.estimatedCostUsd, greaterThan(0));
  });

  test('message.id + requestId が同じ行は二重計上しない', () async {
    final line = usageLine(
      messageId: 'm1',
      requestId: 'r1',
      timestamp: fixedNow,
      input: 100,
    );
    writeJsonl('s1', [line, line]);

    final usage = await repo().aggregateToday();

    expect(usage.inputTokens, 100);
  });

  test('当日より前の行は集計から除外する', () async {
    writeJsonl('s1', [
      usageLine(
        messageId: 'm-old',
        requestId: 'r-old',
        timestamp: fixedNow.subtract(const Duration(days: 2)),
        input: 999,
      ),
      usageLine(
        messageId: 'm-now',
        requestId: 'r-now',
        timestamp: fixedNow,
        input: 7,
      ),
    ]);

    final usage = await repo().aggregateToday();

    expect(usage.inputTokens, 7);
  });

  test('破損行はスキップして残りの集計を継続する', () async {
    writeJsonl('s1', [
      '{ this is not valid json',
      usageLine(
        messageId: 'm1',
        requestId: 'r1',
        timestamp: fixedNow,
        input: 42,
      ),
    ]);

    final usage = await repo().aggregateToday();

    expect(usage.inputTokens, 42);
  });

  test('usage を持たない行は除外する', () async {
    writeJsonl('s1', [
      jsonEncode({
        'type': 'user',
        'timestamp': fixedNow.toUtc().toIso8601String(),
        'message': {'role': 'user', 'content': 'hi'},
      }),
      usageLine(
        messageId: 'm1',
        requestId: 'r1',
        timestamp: fixedNow,
        output: 3,
      ),
    ]);

    final usage = await repo().aggregateToday();

    expect(usage.outputTokens, 3);
    expect(usage.totalTokens, 3);
  });

  test('未知モデルはコスト 0、トークンは集計に算入する', () async {
    writeJsonl('s1', [
      usageLine(
        messageId: 'm1',
        requestId: 'r1',
        timestamp: fixedNow,
        model: 'some-unknown-model',
        input: 1000000,
      ),
    ]);

    final usage = await repo().aggregateToday();

    expect(usage.inputTokens, 1000000);
    expect(usage.estimatedCostUsd, 0);
  });

  test('~/.claude/projects が無い環境では zero を返す', () async {
    final missingHome = await Directory.systemTemp.createTemp('roola_nohome_');
    addTearDown(() => missingHome.delete(recursive: true));

    final usage = await CcUsageRepository(
      now: () => fixedNow,
      homeDirectory: () => missingHome.path,
    ).aggregateToday();

    expect(usage, CcUsage.zero);
  });

  test('HOME が解決できないときも zero を返す', () async {
    final usage = await CcUsageRepository(
      now: () => fixedNow,
      homeDirectory: () => null,
    ).aggregateToday();

    expect(usage, CcUsage.zero);
  });
}
