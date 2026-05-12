// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$homeRoute];

RouteBase get $homeRoute => GoRouteData.$route(
  path: '/',
  factory: $HomeRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'run/:entryId', factory: $RunRoute._fromState),
    GoRouteData.$route(
      path: 'settings',
      factory: $SettingsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'entries/new',
          factory: $EntryNewRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'entries/:entryId',
          factory: $EntryEditRoute._fromState,
        ),
      ],
    ),
  ],
);

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
  static EntryNewRoute _fromState(GoRouterState state) => const EntryNewRoute();

  @override
  String get location => GoRouteData.$location('/settings/entries/new');

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
