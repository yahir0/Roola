import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';

/// 設定・ランチャー管理など「ワークスペースに重ねるモーダル文脈」を、
/// ベゼル付きディスプレイ 1 枚として中央に浮かせるシェル（Polaris / ADR-0054）。
///
/// 戻る山括弧 + タイトルという Material 然としたヘッダ（[MacosWindowAppBar]）を
/// やめ、メイン画面のトップバーはそのままに、背後のワークスペースを薄暗く透かした
/// 上へ「閉じられるパネル」として出す。ルート側は `opaque: false` で push し、
/// 背後にワークスペースを描かせる前提（`router.dart`）。
///
/// 閉じる手段は ✕ ボタン / スクリムのタップ / Esc の 3 つ。いずれも `maybePop`。
class PolarisModalShell extends StatelessWidget {
  const PolarisModalShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.maxWidth = 760,
  });

  /// パネル見出し（全大文字ラックラベルで表示）。
  final String title;

  /// パネル本体。スクロールするコンテンツ（ListView 等）を想定。
  final Widget child;

  /// ヘッダ右側、✕ の左に並べる追加アクション（「追加」等）。
  final List<Widget>? actions;

  /// パネルの最大幅（px）。
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final l10n = AppLocalizations.of(context);
    void close() => Navigator.of(context).maybePop();

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): close},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // スクリム: 背後のワークスペースを薄暗く沈め、タップで閉じる。
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: close,
                  child: ColoredBox(color: tokens.well.withValues(alpha: 0.72)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PolarisTokens.space8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SizedBox(
                      height: double.infinity,
                      child: _Panel(
                        title: title,
                        actions: actions,
                        onClose: close,
                        closeTooltip: l10n.buttonClose,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// モーダルの本体パネル。`well` 地・1px ベゼル・上端ハイライトの「計器
/// ディスプレイ」として浮かせ、ヘッダ（タイトル + アクション + ✕）と本文を
/// ハーラインで分ける。
class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.actions,
    required this.onClose,
    required this.closeTooltip,
    required this.child,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback onClose;
  final String closeTooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return DecoratedBox(
      // 角丸を併用するため、ボーダーは均一色（`line`）にする（Flutter は
      // borderRadius + 非均一ボーダーを許さない）。上端ハイライトは別途
      // 1px の topEdge ラインを内側に重ねて表現する。
      decoration: BoxDecoration(
        color: tokens.well,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 筐体上端が光を受ける 1px ハイライト（ADR-0038 D3）。
            SizedBox(height: 1, child: ColoredBox(color: tokens.topEdge)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PolarisTokens.space6,
                PolarisTokens.space3,
                PolarisTokens.space3,
                PolarisTokens.space3,
              ),
              child: Row(
                children: [
                  Expanded(child: PolarisFieldLabel(title)),
                  if (actions != null) ...[
                    ...actions!,
                    const SizedBox(width: PolarisTokens.space1),
                  ],
                  IconButton(
                    icon: PolarisGlyph.close(color: tokens.textDim),
                    tooltip: closeTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            SizedBox(height: 1, child: ColoredBox(color: tokens.line)),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
