import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';
import 'package:window_manager/window_manager.dart';

/// macOS の信号灯ボタン（close / minimize / maximize）と AppBar の
/// leading が位置で競合しないよう、左側に余白を確保した AppBar。
///
/// `window_manager` の `titleBarStyle: TitleBarStyle.hidden` を使って
/// いるため、信号灯は OS が AppBar の左上に重ねて描画する。標準の
/// `AppBar` をそのまま使うと、自動 back ボタンや leading アイコンが
/// 信号灯と重なって押し分けられない。`leadingWidth` に信号灯ぶんの幅を
/// 確保し、leading をその幅の空 spacer にすることで衝突を避ける。
///
/// 戻る導線は持たない。重ねるモーダル（設定 / ランチャー管理 / ライセンス）は
/// すべて [PolarisModalShell] が自前で閉じる / 戻るを提供するため、ウィンドウ
/// ヘッダ側に back ボタンは不要（ADR-0054 / ADR-0056）。
///
/// [title] は省略可能で、Home / Explorer のようにタブで現在地が示せる
/// 画面ではタイトル文字列を出さずに [AppTabSegments] のような widget を
/// 直接置く前提。
///
/// 空のヘッダ領域は `DragToMoveArea` でドラッグによるウィンドウ移動と
/// ダブルクリックによる最大化に対応する（タイトルバー非表示の代替）。
class MacosWindowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MacosWindowAppBar({
    this.title,
    this.titleSpacing,
    this.actions,
    this.bottom,
    super.key,
  });

  /// macOS の信号灯ボタン領域の幅（px）。
  /// 12px × 3 個 + 各 padding で実測 70〜78px。余裕を見て 80px 取る。
  static const double _trafficLightsWidth = 80;

  /// トップバー（タイトルバー兼用）の高さ（px）。
  /// Material 標準の `kToolbarHeight`（56px）は計器 UI には背が高く、トップ
  /// 側のクロームを重く見せる。信号灯（12px）が収まる下限まで詰め、4px
  /// グリッドに乗る 40px とする（ADR-0038 D6）。
  static const double _toolbarHeight = 40;

  final Widget? title;

  /// [title] の左余白。null だと AppBar 標準（16px）。トップバー左端の信号灯
  /// 領域の直後にワードマーク等を詰めて置きたい場合に小さい値を渡す。
  final double? titleSpacing;

  final List<Widget>? actions;

  /// AppBar の下端に重ねる widget（区切りライン等）。Material の AppBar
  /// `bottom` スロットへそのまま流す。
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(_toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return AppBar(
      title: title,
      titleSpacing: titleSpacing,
      toolbarHeight: _toolbarHeight,
      actions: actions,
      // アクション群が筐体右端に貼り付くと窮屈なので 8px の余白を挟む。
      // `actions` の要素数を変えないので、macOS のタイトル中央寄せ判定
      // （アクション 2 個未満で中央）には影響しない。
      actionsPadding: const EdgeInsets.only(right: PolarisTokens.space2),
      bottom: bottom,
      automaticallyImplyLeading: false,
      // `TitleBarStyle.hidden` でネイティブのタイトルバーを消しているため、
      // OS 標準の「タイトルバーをドラッグで移動 / ダブルクリックで最大化」が
      // 効かない。`flexibleSpace` は leading / title / actions の背面に敷かれ、
      // ボタン等が消費しなかったジェスチャだけを受け取るので、ここに
      // `DragToMoveArea` を置いて空のヘッダ領域でその挙動を再現する。
      // 筐体上端の 1px ハイライト（topEdge）と下端の 1px ヘアライン継ぎ目
      // （line）を重ね、トップバーを「筐体の枠」として見せる（ADR-0038 D3）。
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: tokens.topEdge),
            bottom: BorderSide(color: tokens.line),
          ),
        ),
        child: const DragToMoveArea(child: SizedBox.expand()),
      ),
      // 信号灯ぶんの幅を空 spacer で確保し、title / actions を右へ押し出す。
      leadingWidth: _trafficLightsWidth,
      leading: const SizedBox(width: _trafficLightsWidth),
    );
  }
}
