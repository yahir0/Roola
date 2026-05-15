import 'package:flutter/material.dart';

/// 2 つの子を [axis] 方向に分割し、ドラッグ可能なハンドルでリサイズできる
/// レイアウト（ADR-0026 のスプリッタ）。
///
/// [ratio] は [first] 側の占有比率（0..1）。ハンドルのドラッグで
/// [onRatioChanged] が呼ばれる。比率のクランプは呼び出し側
/// （`workspaceProvider.setTopRatio` / `setLeftRatio`）で行う。
class WorkspaceSplit extends StatelessWidget {
  const WorkspaceSplit({
    required this.axis,
    required this.ratio,
    required this.onRatioChanged,
    required this.first,
    required this.second,
    super.key,
  });

  final Axis axis;
  final double ratio;
  final ValueChanged<double> onRatioChanged;
  final Widget first;
  final Widget second;

  /// ドラッグハンドルの厚み（px）。
  static const double _handleThickness = 6;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final usable = (extent - _handleThickness).clamp(0.0, double.infinity);
        final firstSize = usable * ratio;
        final secondSize = usable - firstSize;
        final isHorizontal = axis == Axis.horizontal;
        final children = <Widget>[
          SizedBox(
            width: isHorizontal ? firstSize : null,
            height: isHorizontal ? null : firstSize,
            child: first,
          ),
          _SplitHandle(
            axis: axis,
            thickness: _handleThickness,
            onDelta: (delta) {
              if (usable <= 0) {
                return;
              }
              onRatioChanged(ratio + delta / usable);
            },
          ),
          SizedBox(
            width: isHorizontal ? secondSize : null,
            height: isHorizontal ? null : secondSize,
            child: second,
          ),
        ];
        return isHorizontal
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }
}

/// スプリッタのドラッグハンドル。中央に区切り線を描き、ホバーで
/// リサイズカーソルに変える。
class _SplitHandle extends StatelessWidget {
  const _SplitHandle({
    required this.axis,
    required this.thickness,
    required this.onDelta,
  });

  final Axis axis;
  final double thickness;
  final ValueChanged<double> onDelta;

  @override
  Widget build(BuildContext context) {
    final isHorizontal = axis == Axis.horizontal;
    return MouseRegion(
      cursor: isHorizontal
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: isHorizontal
            ? (d) => onDelta(d.delta.dx)
            : null,
        onVerticalDragUpdate: isHorizontal ? null : (d) => onDelta(d.delta.dy),
        child: SizedBox(
          width: isHorizontal ? thickness : null,
          height: isHorizontal ? null : thickness,
          child: Center(
            child: Container(
              width: isHorizontal ? 1 : double.infinity,
              height: isHorizontal ? double.infinity : 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}
