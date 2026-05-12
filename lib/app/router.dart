import 'package:claude_skills_launcher/ui/home/home_page.dart';
import 'package:claude_skills_launcher/ui/run/run_page.dart';
import 'package:claude_skills_launcher/ui/settings/entry_edit_page.dart';
import 'package:claude_skills_launcher/ui/settings/settings_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'router.g.dart';

/// アプリの go_router インスタンス。
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
  );
});

/// ホーム画面ルート (`/`)。
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<RunRoute>(path: 'run/:entryId'),
    TypedGoRoute<SettingsRoute>(
      path: 'settings',
      routes: <TypedGoRoute<GoRouteData>>[
        TypedGoRoute<EntryNewRoute>(path: 'entries/new'),
        TypedGoRoute<EntryEditRoute>(path: 'entries/:entryId'),
      ],
    ),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

/// 実行画面ルート (`/run/:entryId`)。
class RunRoute extends GoRouteData with $RunRoute {
  const RunRoute({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RunPage(entryId: entryId);
}

/// 設定画面ルート (`/settings`)。
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

/// エントリ新規作成ルート (`/settings/entries/new`)。
class EntryNewRoute extends GoRouteData with $EntryNewRoute {
  const EntryNewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const EntryEditPage(entryId: null);
}

/// エントリ編集ルート (`/settings/entries/:entryId`)。
class EntryEditRoute extends GoRouteData with $EntryEditRoute {
  const EntryEditRoute({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EntryEditPage(entryId: entryId);
}
