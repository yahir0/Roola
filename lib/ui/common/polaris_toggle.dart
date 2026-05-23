import 'package:flutter/material.dart';
import 'package:roola/app/theme.dart';

/// [PolarisToggle] の 1 セグメント定義。
class PolarisToggleSegment<T> {
  const PolarisToggleSegment({
    required this.value,
    required this.label,
    this.iconBuilder,
  });

  /// このセグメントが表す値。
  final T value;

  /// セグメントのラベル。
  final String label;

  /// 任意の先行アイコン。選択状態に応じた色（`color`）を受け取って描く。
  /// 主にモノライングリフ（[PolarisGlyph]）を渡す。
  final Widget Function(Color color)? iconBuilder;
}

/// Polaris のセグメント切替トグル（ADR-0038）。
///
/// Material の `SegmentedButton` は「外枠 + セグメント間の仕切り線 + 薄塗りの
/// ピル + チェックマーク」という M3 特有の見た目で、計器 UI の中で浮く。本
/// ウィジェットは外枠 1px のみ・仕切り線なし・R=4px の機械加工筐体とし、選択中
/// セグメントだけをアクセントでソリッド塗りする（非選択は地のまま）。ハードウェアの
/// モードセレクタに寄せた表現。
class PolarisToggle<T> extends StatelessWidget {
  const PolarisToggle({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  /// 左から並べるセグメント。
  final List<PolarisToggleSegment<T>> segments;

  /// 現在選択中の値。
  final T selected;

  /// 選択変更コールバック。`null` の場合は操作不可（淡色表示）。
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final enabled = onChanged != null;
    final radius = BorderRadius.circular(tokens.radius);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: tokens.line),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final segment in segments)
                  _Segment<T>(
                    segment: segment,
                    isSelected: segment.value == selected,
                    onTap: enabled ? () => onChanged!(segment.value) : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.isSelected,
    required this.onTap,
  });

  final PolarisToggleSegment<T> segment;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    // フラット指向（ADR-0038）。選択はアクセントのベタ塗りでなく、低透過の
    // 淡いアクセント面 + アクセント色の文字で静かに示す。
    final fg = isSelected ? tokens.accent : tokens.textDim;
    final icon = segment.iconBuilder;
    return InkWell(
      onTap: onTap,
      hoverColor: isSelected ? Colors.transparent : tokens.surface,
      child: ColoredBox(
        color: isSelected
            ? tokens.accent.withValues(alpha: 0.16)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PolarisTokens.space3,
            vertical: PolarisTokens.space2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon(fg),
                const SizedBox(width: PolarisTokens.space2),
              ],
              Text(segment.label, style: tokens.body.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
