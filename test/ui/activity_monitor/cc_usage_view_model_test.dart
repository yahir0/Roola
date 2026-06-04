import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/cc_usage/cc_usage.dart';
import 'package:roola/data/cc_usage/cc_usage_repository.dart';
import 'package:roola/ui/activity_monitor/cc_usage_view_model.dart';

/// projectsDirectory を持たない（= 監視を張らない）固定値リポジトリ。
/// 初回集計とフォールバックを決定的に検証するために使う。
class _FakeCcUsageRepository extends CcUsageRepository {
  _FakeCcUsageRepository(this._result, {this.throwOnAggregate = false});

  final CcUsage _result;
  final bool throwOnAggregate;

  @override
  Directory? projectsDirectory() => null;

  @override
  Future<CcUsage> aggregateToday() async {
    if (throwOnAggregate) throw Exception('boom');
    return _result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('build 後に初回集計の結果が state へ反映される', () async {
    const expected = CcUsage(
      inputTokens: 100,
      outputTokens: 20,
      cacheReadTokens: 5,
      cacheCreationTokens: 50,
      estimatedCostUsd: 1.23,
    );
    final container = ProviderContainer(
      overrides: [
        ccUsageRepositoryProvider.overrideWithValue(
          _FakeCcUsageRepository(expected),
        ),
      ],
    );
    addTearDown(container.dispose);

    // build 直後はゼロ、非同期の初回集計後に確定値へ変わる。
    expect(container.read(ccUsageProvider), CcUsage.zero);
    await _settle();

    expect(container.read(ccUsageProvider), expected);
  });

  test('集計が例外を投げても state は直近値（zero）を維持する', () async {
    final container = ProviderContainer(
      overrides: [
        ccUsageRepositoryProvider.overrideWithValue(
          _FakeCcUsageRepository(CcUsage.zero, throwOnAggregate: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(ccUsageProvider), CcUsage.zero);
    await _settle();

    expect(container.read(ccUsageProvider), CcUsage.zero);
  });

  test('JSONL の追記を監視して state を更新する', () async {
    final tempHome = await Directory.systemTemp.createTemp('roola_ccvm_');
    addTearDown(() => tempHome.delete(recursive: true));
    Directory('${tempHome.path}/.claude/projects/proj-a')
        .createSync(recursive: true);

    final container = ProviderContainer(
      overrides: [
        ccUsageRepositoryProvider.overrideWithValue(
          // 当日判定を実時刻に合わせ、書き込むファイルの mtime / timestamp が
          // 確実に「当日」になるようにする。
          CcUsageRepository(homeDirectory: () => tempHome.path),
        ),
      ],
    );
    addTearDown(container.dispose);

    // 初回集計（空ディレクトリ）→ ゼロ。
    container.read(ccUsageProvider);
    await _settle();
    expect(container.read(ccUsageProvider).totalTokens, 0);

    // 当日の usage 行を追記する。
    final now = DateTime.now();
    File('${tempHome.path}/.claude/projects/proj-a/s1.jsonl').writeAsStringSync(
      '{"type":"assistant","requestId":"r1","timestamp":'
      '"${now.toUtc().toIso8601String()}",'
      '"message":{"id":"m1","model":"claude-opus-4-8",'
      '"usage":{"input_tokens":123,"output_tokens":0,'
      '"cache_read_input_tokens":0,"cache_creation_input_tokens":0}}}',
    );

    // デバウンス（400ms）+ FSEvents 配信の余裕を見て待つ。
    await Future<void>.delayed(const Duration(seconds: 2));

    expect(container.read(ccUsageProvider).inputTokens, 123);
  });
}

/// 非同期の初回集計（マイクロタスク + I/O）が落ち着くまで待つ。
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 100));
