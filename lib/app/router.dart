import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/ui/about/license_browser_page.dart';
import 'package:roola/ui/consent/terms_page.dart';
import 'package:roola/ui/launchers/entry_edit_page.dart';
import 'package:roola/ui/launchers/launcher_management_page.dart';
import 'package:roola/ui/settings/keybindings_page.dart';
import 'package:roola/ui/settings/settings_page.dart';
import 'package:roola/ui/workspace/workspace_page.dart';

part 'router.g.dart';

/// 設定 / ランチャー管理など「ワークスペースに重ねるモーダル文脈」を push する
/// ためのページ。`opaque: false` で背後のワークスペースを描かせ、遷移アニメは
/// 抑制する（エクスプローラ内ナビと体感を揃える / ADR-0038 D7・ADR-0054）。
/// 中身は [PolarisModalShell] でスクリム + ベゼルパネルとして出す前提。
Page<void> _modalPage(Widget child) => CustomTransitionPage<void>(
  opaque: false,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
  transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  child: child,
);

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
      _modalPage(const SettingsPage());
}

/// キーボードショートカット設定ルート (`/keybindings`)。全コマンドの一覧と
/// キー割り当て編集（ADR-0033）。設定画面とメニューバーから push。
/// 遷移アニメを抑制する理由は `SettingsRoute` 参照。
@TypedGoRoute<KeybindingsRoute>(path: '/keybindings')
class KeybindingsRoute extends GoRouteData with $KeybindingsRoute {
  const KeybindingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _modalPage(const KeybindingsPage());
}

/// OSS ライセンス一覧ルート (`/licenses`)。About ダイアログの「ライセンスを
/// 表示」から push（ADR-0040）。設定 / ランチャー管理と同じ [PolarisModalShell]
/// のモーダルとして出し、一覧 → 詳細はモーダル内の内部 state で行き来する
/// （ADR-0056）。遷移アニメを抑制する理由は `SettingsRoute` 参照。
@TypedGoRoute<LicensesRoute>(path: '/licenses')
class LicensesRoute extends GoRouteData with $LicensesRoute {
  const LicensesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _modalPage(const LicenseBrowserPage());
}

/// 利用規約の閲覧ルート (`/terms`)。設定画面のプライバシーセクションから
/// push（ADR-0065）。起動時の同意モーダル（`TermsConsentGate`）はルートでは
/// なく builder チェーンのオーバーレイなので、こちらは閲覧専用。
/// 遷移アニメを抑制する理由は `SettingsRoute` 参照。
@TypedGoRoute<TermsRoute>(path: '/terms')
class TermsRoute extends GoRouteData with $TermsRoute {
  const TermsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _modalPage(const TermsPage());
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
      _modalPage(const LauncherManagementPage());
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
  Page<void> buildPage(BuildContext context, GoRouterState state) => _modalPage(
    EntryEditPage(
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
      _modalPage(EntryEditPage(entryId: entryId));
}
