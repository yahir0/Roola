import 'package:flutter/material.dart';

/// macOS の信号灯ボタン（close / minimize / maximize）と AppBar の
/// leading が位置で競合しないよう、左側に余白を確保した AppBar。
///
/// `window_manager` の `titleBarStyle: TitleBarStyle.hidden` を使って
/// いるため、信号灯は OS が AppBar の左上に重ねて描画する。標準の
/// `AppBar` をそのまま使うと、自動 back ボタンや leading アイコンが
/// 信号灯と重なって押し分けられない。`leadingWidth` に信号灯ぶんの幅を
/// 加算し、leading widget を右側に押し出すことで衝突を避ける。
class MacosWindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MacosWindowAppBar({required this.title, this.actions, super.key});

  /// macOS の信号灯ボタン領域の幅（px）。
  /// 12px × 3 個 + 各 padding で実測 70〜78px。余裕を見て 80px 取る。
  static const double _trafficLightsWidth = 80;

  /// 標準 `BackButton` の描画幅。
  static const double _backButtonWidth = 48;

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      title: title,
      actions: actions,
      automaticallyImplyLeading: false,
      leadingWidth: _trafficLightsWidth + (canPop ? _backButtonWidth : 0),
      leading: canPop
          ? const Padding(
              padding: EdgeInsets.only(left: _trafficLightsWidth),
              child: BackButton(),
            )
          : const SizedBox(width: _trafficLightsWidth),
    );
  }
}
