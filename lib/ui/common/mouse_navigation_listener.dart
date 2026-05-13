import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/ui/explorer/explorer_view_model.dart';

/// マウスのサイドボタン（戻る / 進む）でアプリ内ナビゲーションを操作する Listener。
///
/// macOS で多ボタンマウスの戻る / 進むボタンを押したときに飛ぶ
/// `kBackMouseButton` / `kForwardMouseButton` の PointerDown を拾って、
/// コンテキストに応じたナビゲーションを実行する:
///
/// - **戻る**:
///   - Run / Settings / EntryNew / EntryEdit など push されたルート上では
///     `GoRouter.pop()` でひとつ前のルートへ
///   - エクスプローラタブのときは `ExplorerViewModel.goBack()` で履歴を遡る
///   - それ以外（ホームタブ）では何もしない
/// - **進む**:
///   - エクスプローラタブのときは `ExplorerViewModel.goForward()` で履歴を
///     辿り直す
///   - それ以外では何もしない（GoRouter は forward スタックを持たないため
///     push 系ルートでは進めない）
///
/// アプリ最上位の builder で `child` をラップして使う。
class MouseNavigationListener extends ConsumerWidget {
  const MouseNavigationListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      onPointerDown: (event) {
        if (event.kind != PointerDeviceKind.mouse) {
          return;
        }
        // `event.buttons` は「現在押されている全ボタンのビットマスク」。
        // 戻る / 進むボタンだけを押した場合のみ反応するよう厳密一致で
        // 判定し、他ボタンとの同時押しによる二重発火を避ける。
        if (event.buttons == kBackMouseButton) {
          _handleBack(ref);
        } else if (event.buttons == kForwardMouseButton) {
          _handleForward(ref);
        }
      },
      child: child,
    );
  }

  void _handleBack(WidgetRef ref) {
    final router = ref.read(routerProvider);
    if (router.canPop()) {
      router.pop();
      return;
    }
    // root レベル（シェル内のタブ）にいるとき:
    // エクスプローラ → 履歴を 1 つ戻る。それ以外（ホーム）は no-op。
    if (_isOnExplorer(router)) {
      ref.read(explorerViewModelProvider.notifier).goBack();
    }
  }

  void _handleForward(WidgetRef ref) {
    final router = ref.read(routerProvider);
    if (_isOnExplorer(router)) {
      ref.read(explorerViewModelProvider.notifier).goForward();
    }
  }

  bool _isOnExplorer(GoRouter router) {
    final uri = router.routerDelegate.currentConfiguration.uri.toString();
    return uri.startsWith('/explorer');
  }
}
