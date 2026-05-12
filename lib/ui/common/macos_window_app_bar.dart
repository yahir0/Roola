import 'package:flutter/material.dart';

/// macOS の信号灯ボタン（close / minimize / maximize）と AppBar の
/// leading が位置で競合しないよう、左側に余白を確保した AppBar。
///
/// `window_manager` の `titleBarStyle: TitleBarStyle.hidden` を使って
/// いるため、信号灯は OS が AppBar の左上に重ねて描画する。標準の
/// `AppBar` をそのまま使うと、自動 back ボタンや leading アイコンが
/// 信号灯と重なって押し分けられない。`leadingWidth` に信号灯ぶんの幅を
/// 加算し、leading widget を右側に押し出すことで衝突を避ける。
///
/// 通常はナビゲーションスタックを `Navigator.pop` する back ボタンを
/// 自動表示するが、Explorer のように「同じ route のまま内部状態を
/// 巻き戻したい」ケースのために [onBack] を渡すと、push 履歴の有無に
/// 関係なくその callback を back の動作として使う。
class MacosWindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MacosWindowAppBar({
    required this.title,
    this.actions,
    this.onBack,
    super.key,
  });

  /// macOS の信号灯ボタン領域の幅（px）。
  /// 12px × 3 個 + 各 padding で実測 70〜78px。余裕を見て 80px 取る。
  static const double _trafficLightsWidth = 80;

  /// 標準 `BackButton` の描画幅。
  static const double _backButtonWidth = 48;

  final Widget title;
  final List<Widget>? actions;

  /// back ボタンの動作を上書きする callback。null の場合は
  /// `Navigator.canPop()` を見て自動的に pop する。`null` ではないが
  /// 値も null（= `() {} as VoidCallback?` 的に渡せない設計）。「back を
  /// 表示しない」を意図する場合は呼び出し側で意図的に省略するか、
  /// callback として `null` を渡すと back ボタンが消える。
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBack = onBack != null || canPop;
    return AppBar(
      title: title,
      actions: actions,
      automaticallyImplyLeading: false,
      leadingWidth: _trafficLightsWidth + (showBack ? _backButtonWidth : 0),
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: _trafficLightsWidth),
              child: BackButton(onPressed: onBack),
            )
          : const SizedBox(width: _trafficLightsWidth),
    );
  }
}
