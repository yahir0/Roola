import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// 配下のページから `StatefulNavigationShell` にアクセスするための
/// InheritedWidget。
///
/// `StatefulNavigationShell.maybeOf(context)` は State を返すため、
/// `currentIndex` の変化に対する rebuild 購読が直感的でない。代わりに
/// シェル直下でこの scope を被せ、`updateShouldNotify` で currentIndex の
/// 変化を伝える。
class AppShellScope extends InheritedWidget {
  const AppShellScope({required this.shell, required super.child, super.key});

  final StatefulNavigationShell shell;

  static StatefulNavigationShell? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>()?.shell;
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      shell.currentIndex != oldWidget.shell.currentIndex;
}
