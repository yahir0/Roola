// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $explorerRoute,
  $settingsRoute,
  $keybindingsRoute,
  $licensesRoute,
  $termsRoute,
  $launcherManagementRoute,
];

RouteBase get $explorerRoute =>
    GoRouteData.$route(path: '/explorer', factory: $ExplorerRoute._fromState);

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

RouteBase get $settingsRoute =>
    GoRouteData.$route(path: '/settings', factory: $SettingsRoute._fromState);

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

RouteBase get $keybindingsRoute => GoRouteData.$route(
  path: '/keybindings',
  factory: $KeybindingsRoute._fromState,
);

mixin $KeybindingsRoute on GoRouteData {
  static KeybindingsRoute _fromState(GoRouterState state) =>
      const KeybindingsRoute();

  @override
  String get location => GoRouteData.$location('/keybindings');

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

RouteBase get $licensesRoute =>
    GoRouteData.$route(path: '/licenses', factory: $LicensesRoute._fromState);

mixin $LicensesRoute on GoRouteData {
  static LicensesRoute _fromState(GoRouterState state) => const LicensesRoute();

  @override
  String get location => GoRouteData.$location('/licenses');

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

RouteBase get $termsRoute =>
    GoRouteData.$route(path: '/terms', factory: $TermsRoute._fromState);

mixin $TermsRoute on GoRouteData {
  static TermsRoute _fromState(GoRouterState state) => const TermsRoute();

  @override
  String get location => GoRouteData.$location('/terms');

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

RouteBase get $launcherManagementRoute => GoRouteData.$route(
  path: '/launchers',
  factory: $LauncherManagementRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'new', factory: $EntryNewRoute._fromState),
    GoRouteData.$route(path: ':entryId', factory: $EntryEditRoute._fromState),
  ],
);

mixin $LauncherManagementRoute on GoRouteData {
  static LauncherManagementRoute _fromState(GoRouterState state) =>
      const LauncherManagementRoute();

  @override
  String get location => GoRouteData.$location('/launchers');

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
    '/launchers/new',
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
  String get location =>
      GoRouteData.$location('/launchers/${Uri.encodeComponent(_self.entryId)}');

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
