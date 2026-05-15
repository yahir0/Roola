import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/ui/launchers/entry_edit_page.dart';
import 'package:roola/ui/launchers/launcher_management_page.dart';
import 'package:roola/ui/settings/settings_page.dart';
import 'package:roola/ui/workspace/workspace_page.dart';

part 'router.g.dart';

/// 全画面共通の root Navigator キー。
///
/// `MaterialApp.router` の `builder` で配置している `WindowCloseGuard` の
/// `BuildContext` は Navigator の外側にいるため、そのまま `showDialog` を
/// 呼んでも何も表示されない（route 系のダイアログは Navigator 配下の context
/// を要求するため）。このキー経由で Navigator の `currentContext` を取得して
/// 終了確認ダイアログを表示できるようにする。
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// アプリの go_router インスタンス。
///
/// ADR-0014 で Home タブ廃止・Explorer メイン化したため、初期ロケーションは
/// `/explorer`。Settings / LauncherManagement / EntryEdit は `.push()` で上に
/// 重ねる top-level / nested route。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/explorer',
    navigatorKey: rootNavigatorKey,
    routes: $appRoutes,
  );
});

/// メイン画面ルート (`/explorer`)。3 ペインタブ式ワークスペース（ADR-0026）。
///
/// パスは互換性のため `/explorer` のまま。描画するのは [WorkspacePage]。
@TypedGoRoute<ExplorerRoute>(path: '/explorer')
class ExplorerRoute extends GoRouteData with $ExplorerRoute {
  const ExplorerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WorkspacePage();
}

/// 設定画面ルート (`/settings`)。外観 / claude ヘルスのみ。
///
/// `buildPage` で `NoTransitionPage` を返しているのは、macOS のデフォルト
/// 「右から slide-in」遷移を抑制してエクスプローラ内ナビゲーションと体感を
/// 揃えるため。エクスプローラ自体はルートを切替えず内部 state で画面を差し
/// 替えるので遷移アニメが無く、Settings / LauncherManagement / EntryEdit
/// だけ別の遷移挙動だと違和感があった。
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: SettingsPage());
}

/// ランチャー管理画面ルート (`/launchers`)。登録済みエントリの一覧 + 追加 /
/// 編集 / 削除導線。サイドバーの「管理…」から push。
/// 遷移アニメを抑制する理由は `SettingsRoute` 参照。
@TypedGoRoute<LauncherManagementRoute>(
  path: '/launchers',
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<EntryNewRoute>(path: 'new'),
    TypedGoRoute<EntryEditRoute>(path: ':entryId'),
  ],
)
class LauncherManagementRoute extends GoRouteData
    with $LauncherManagementRoute {
  const LauncherManagementRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: LauncherManagementPage());
}

/// エントリ新規作成ルート (`/launchers/new`)。
///
/// エクスプローラから登録メニュー経由で開く際に、リポジトリパスと Skill 名
/// を事前埋め込みするための optional クエリパラメータを持つ。
class EntryNewRoute extends GoRouteData with $EntryNewRoute {
  const EntryNewRoute({this.initialRepositoryPath, this.initialSkillName});

  final String? initialRepositoryPath;
  final String? initialSkillName;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      NoTransitionPage(
        child: EntryEditPage(
          entryId: null,
          initialRepositoryPath: initialRepositoryPath,
          initialSkillName: initialSkillName,
        ),
      );
}

/// エントリ編集ルート (`/launchers/:entryId`)。
class EntryEditRoute extends GoRouteData with $EntryEditRoute {
  const EntryEditRoute({required this.entryId});

  final String entryId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      NoTransitionPage(child: EntryEditPage(entryId: entryId));
}
