import 'package:claude_skills_launcher/ui/explorer/explorer_page.dart';
import 'package:claude_skills_launcher/ui/home/home_page.dart';
import 'package:claude_skills_launcher/ui/run/adhoc_run_view_model.dart';
import 'package:claude_skills_launcher/ui/run/run_page.dart';
import 'package:claude_skills_launcher/ui/settings/entry_edit_page.dart';
import 'package:claude_skills_launcher/ui/settings/settings_page.dart';
import 'package:claude_skills_launcher/ui/shell/app_shell_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'router.g.dart';

/// アプリの go_router インスタンス。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: '/', routes: $appRoutes);
});

/// 画面上部の Home/Explorer タブを束ねるシェル。
///
/// `StatefulShellRoute.indexedStack` を使うことで、タブ切り替え時に
/// 非アクティブ側の Navigator が破棄されない（state 保持）。
/// Run/Settings 等はこのシェルの **外側** に top-level route として置く
/// ことで、`.push()` 経由でシェル全体（タブ含む）を覆って表示される。
/// 戻るボタン押下時は root navigator が pop して、元々アクティブだった
/// タブ（とそのページ state）が復元される。
@TypedStatefulShellRoute<AppShellRoute>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranch>(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<HomeRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<ExplorerBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ExplorerRoute>(path: '/explorer'),
      ],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppShellScope(shell: navigationShell, child: navigationShell);
  }
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class ExplorerBranch extends StatefulShellBranchData {
  const ExplorerBranch();
}

/// ホーム画面ルート (`/`)。
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

/// エクスプローラ画面ルート (`/explorer`)。
class ExplorerRoute extends GoRouteData with $ExplorerRoute {
  const ExplorerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ExplorerPage();
}

/// 永続エントリ実行画面ルート (`/run/:entryId`)。
///
/// シェル外の top-level route として定義し、`.push()` で起動することで
/// 「シェル全体（タブ含む）を覆って表示し、back で起動元タブへ戻る」
/// 挙動になる。
@TypedGoRoute<RunRoute>(path: '/run/:entryId')
class RunRoute extends GoRouteData with $RunRoute {
  const RunRoute({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RunPage.fromEntry(entryId);
}

/// ad-hoc セッション実行画面ルート (`/run-adhoc/:adhocId`)。
///
/// `AdhocRunArgs` は URL 化できないため `extra` で渡す。アプリ内遷移専用で、
/// URL 直接アクセスでは復元できない（その場合は引数不足で例外）。
@TypedGoRoute<RunAdhocRoute>(path: '/run-adhoc/:adhocId')
class RunAdhocRoute extends GoRouteData with $RunAdhocRoute {
  const RunAdhocRoute({required this.adhocId, required this.$extra});

  final String adhocId;
  final AdhocRunArgs $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RunPage.fromAdhoc($extra);
}

/// 設定画面ルート (`/settings`)。
@TypedGoRoute<SettingsRoute>(
  path: '/settings',
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<EntryNewRoute>(path: 'entries/new'),
    TypedGoRoute<EntryEditRoute>(path: 'entries/:entryId'),
  ],
)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

/// エントリ新規作成ルート (`/settings/entries/new`)。
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

/// エントリ編集ルート (`/settings/entries/:entryId`)。
class EntryEditRoute extends GoRouteData with $EntryEditRoute {
  const EntryEditRoute({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EntryEditPage(entryId: entryId);
}
