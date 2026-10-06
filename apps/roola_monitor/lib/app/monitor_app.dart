import 'package:flutter/material.dart';
import 'package:polaris/polaris.dart';
import 'package:roola_activity/ui/activity_dashboard/activity_dashboard_view.dart';
import 'package:roola_monitor/app/monitor_menu_bar.dart';

/// Roola Monitor のルート Widget（ADR-0069 D7）。
///
/// ウィンドウ全体に計器盤を置くだけの 1 画面構成。ルーティングは持たない。
/// ライセンス一覧（メニューから開く）のためだけに Navigator を使う。
class MonitorApp extends StatelessWidget {
  const MonitorApp({super.key});

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roola Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.polaris(),
      scrollBehavior: const PolarisScrollBehavior(),
      navigatorKey: _navigatorKey,
      home: MonitorMenuBar(
        navigatorKey: _navigatorKey,
        // ツールバーのトグルは InkResponse を使うため Material の祖先が要る。
        // ウィンドウは常に表示中なので、計器盤は常にアクティブ。
        child: const Scaffold(body: ActivityDashboardView(isActive: true)),
      ),
    );
  }
}
