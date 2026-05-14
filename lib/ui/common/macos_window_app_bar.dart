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
///
/// [onForward] を渡すと back の右隣にブラウザ風の進むボタンも表示する。
/// Explorer のディレクトリ履歴ナビゲーション専用で、Settings 等の
/// 単純な pop で済む画面では渡さない（null だと進むボタンは描画されない）。
///
/// [title] は省略可能で、Home / Explorer のようにタブで現在地が示せる
/// 画面ではタイトル文字列を出さずに [AppTabSegments] のような widget を
/// 直接置く前提。
class MacosWindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MacosWindowAppBar({
    this.title,
    this.actions,
    this.onBack,
    this.onForward,
    this.bottom,
    super.key,
  });

  /// macOS の信号灯ボタン領域の幅（px）。
  /// 12px × 3 個 + 各 padding で実測 70〜78px。余裕を見て 80px 取る。
  static const double _trafficLightsWidth = 80;

  /// 標準 `BackButton` / 進むボタンの描画幅。
  static const double _navButtonWidth = 48;

  final Widget? title;
  final List<Widget>? actions;

  /// back ボタンの動作を上書きする callback。null の場合は
  /// `Navigator.canPop()` を見て自動的に pop する。`null` ではないが
  /// 値も null（= `() {} as VoidCallback?` 的に渡せない設計）。「back を
  /// 表示しない」を意図する場合は呼び出し側で意図的に省略するか、
  /// callback として `null` を渡すと back ボタンが消える。
  final VoidCallback? onBack;

  /// 進むボタンの動作。null だと進むボタン自体を描画しない（back のみ）。
  /// Explorer の履歴 forward など、画面ごとに「進む」概念がある場合のみ
  /// 渡す。
  final VoidCallback? onForward;

  /// AppBar の下端に重ねる widget（区切りライン等）。Material の AppBar
  /// `bottom` スロットへそのまま流す。
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBack = onBack != null || canPop;
    final showForward = onForward != null;
    final navButtonsWidth =
        (showBack ? _navButtonWidth : 0) + (showForward ? _navButtonWidth : 0);
    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      automaticallyImplyLeading: false,
      leadingWidth: _trafficLightsWidth + navButtonsWidth,
      leading: navButtonsWidth == 0
          ? const SizedBox(width: _trafficLightsWidth)
          : Padding(
              padding: const EdgeInsets.only(left: _trafficLightsWidth),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Material の BackButton をそのまま使うと、macOS では
                  // `Icons.arrow_back_ios_new_rounded`（細いシェブロン）に
                  // 切り替わるが、forward には対応する自動 widget が無い。
                  // 両者を手動で同じ icon family に揃えるため、back も
                  // IconButton で書き下す。
                  if (showBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      tooltip: '戻る',
                      onPressed: onBack,
                    ),
                  if (showForward)
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      tooltip: '進む',
                      onPressed: onForward,
                    ),
                ],
              ),
            ),
    );
  }
}
