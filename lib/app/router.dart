import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/ui/explorer/explorer_page.dart';
import 'package:roola/ui/launchers/entry_edit_page.dart';
import 'package:roola/ui/launchers/launcher_management_page.dart';
import 'package:roola/ui/settings/settings_page.dart';

part 'router.g.dart';

/// アプリの go_router インスタンス。
///
/// ADR-0014 で Home タブ廃止・Explorer メイン化したため、初期ロケーションは
/// `/explorer`。Settings / LauncherManagement / EntryEdit は `.push()` で上に
/// 重ねる top-level / nested route。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/explorer', routes: $appRoutes);
});

/// エクスプローラ画面ルート (`/explorer`)。Roola のメイン UI。
@TypedGoRoute<ExplorerRoute>(path: '/explorer')
class ExplorerRoute extends GoRouteData with $ExplorerRoute {
  const ExplorerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ExplorerPage();
}

/// 設定画面ルート (`/settings`)。外観 / claude ヘルスのみ。
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

/// ランチャー管理画面ルート (`/launchers`)。登録済みエントリの一覧 + 追加 /
/// 編集 / 削除導線。サイドバーの「管理…」から push。
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
  Widget build(BuildContext context, GoRouterState state) =>
      const LauncherManagementPage();
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
  Widget build(BuildContext context, GoRouterState state) => EntryEditPage(
    entryId: null,
    initialRepositoryPath: initialRepositoryPath,
    initialSkillName: initialSkillName,
  );
}

/// エントリ編集ルート (`/launchers/:entryId`)。
class EntryEditRoute extends GoRouteData with $EntryEditRoute {
  const EntryEditRoute({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EntryEditPage(entryId: entryId);
}
