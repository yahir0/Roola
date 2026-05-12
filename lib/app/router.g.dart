// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $appShellRoute,
  $runRoute,
  $runAdhocRoute,
  $settingsRoute,
];

RouteBase get $appShellRoute => StatefulShellRouteData.$route(
  factory: $AppShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [GoRouteData.$route(path: '/', factory: $HomeRoute._fromState)],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/explorer',
          factory: $ExplorerRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $AppShellRouteExtension on AppShellRoute {
  static AppShellRoute _fromState(GoRouterState state) => const AppShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ExplorerRoute on GoRouteData {
  static ExplorerRoute _fromState(GoRouterState state) => const ExplorerRoute();

  @override
  String get location => GoRouteData.$location('/explorer');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $runRoute =>
    GoRouteData.$route(path: '/run/:entryId', factory: $RunRoute._fromState);

mixin $RunRoute on GoRouteData {
  static RunRoute _fromState(GoRouterState state) =>
      RunRoute(entryId: state.pathParameters['entryId']!);

  RunRoute get _self => this as RunRoute;

  @override
  String get location =>
      GoRouteData.$location('/run/${Uri.encodeComponent(_self.entryId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $runAdhocRoute => GoRouteData.$route(
  path: '/run-adhoc/:adhocId',
  factory: $RunAdhocRoute._fromState,
);

mixin $RunAdhocRoute on GoRouteData {
  static RunAdhocRoute _fromState(GoRouterState state) => RunAdhocRoute(
    adhocId: state.pathParameters['adhocId']!,
    $extra: state.extra as AdhocRunArgs,
  );

  RunAdhocRoute get _self => this as RunAdhocRoute;

  @override
  String get location =>
      GoRouteData.$location('/run-adhoc/${Uri.encodeComponent(_self.adhocId)}');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',
  factory: $SettingsRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'entries/new', factory: $EntryNewRoute._fromState),
    GoRouteData.$route(
      path: 'entries/:entryId',
      factory: $EntryEditRoute._fromState,
    ),
  ],
);

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $EntryNewRoute on GoRouteData {
  static EntryNewRoute _fromState(GoRouterState state) => EntryNewRoute(
    initialRepositoryPath: state.uri.queryParameters['initial-repository-path'],
    initialSkillName: state.uri.queryParameters['initial-skill-name'],
  );

  EntryNewRoute get _self => this as EntryNewRoute;

  @override
  String get location => GoRouteData.$location(
    '/settings/entries/new',
    queryParams: {
      if (_self.initialRepositoryPath != null)
        'initial-repository-path': _self.initialRepositoryPath,
      if (_self.initialSkillName != null)
        'initial-skill-name': _self.initialSkillName,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $EntryEditRoute on GoRouteData {
  static EntryEditRoute _fromState(GoRouterState state) =>
      EntryEditRoute(entryId: state.pathParameters['entryId']!);

  EntryEditRoute get _self => this as EntryEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/settings/entries/${Uri.encodeComponent(_self.entryId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
