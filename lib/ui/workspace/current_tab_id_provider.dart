import 'package:hooks_riverpod/hooks_riverpod.dart';

/// タブ body 配下の widget に「自分が属するタブ id」を配るための Provider。
///
/// 既定では `throw` する。各タブ body を包む `ProviderScope` で
/// `currentTabIdProvider.overrideWithValue(tabId)` して注入し、子 widget は
/// `ref.watch(currentTabIdProvider)` で tabId を取得して per-tab の family
/// プロバイダ（`explorerViewModelProvider` など）へアクセスする（ADR-0027）。
///
/// 注意: override するのはこの Provider（id 配布）のみ。family プロバイダ
/// 本体はルートスコープに置くこと。nested scope に置くと scope unmount で
/// 状態が破棄される。
final currentTabIdProvider = Provider<String>(
  (ref) => throw StateError(
    'currentTabIdProvider はタブ body の ProviderScope で '
    'overrideWithValue して使う（ADR-0027）',
  ),
);
