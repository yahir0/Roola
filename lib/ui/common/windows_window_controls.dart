import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Windows 専用のウィンドウ操作ボタン（最小化 / 最大化 / 閉じる）。
///
/// `titleBarStyle: TitleBarStyle.hidden` でネイティブタイトルバーを非表示にして
/// いるため、Flutter 側で代替ボタンを提供する。閉じるは `windowManager.close()`
/// 経由で [WindowCloseGuard] に委譲し、セッション確認ダイアログを経由させる。
class WindowsWindowControls extends StatefulWidget {
  const WindowsWindowControls({super.key});

  @override
  State<WindowsWindowControls> createState() => _WindowsWindowControlsState();
}

class _WindowsWindowControlsState extends State<WindowsWindowControls>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((v) {
      if (mounted) setState(() => _isMaximized = v);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.remove,
          tooltip: '最小化',
          onPressed: windowManager.minimize,
        ),
        _ControlButton(
          icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
          tooltip: _isMaximized ? '元のサイズに戻す' : '最大化',
          onPressed: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        _ControlButton(
          icon: Icons.close,
          tooltip: '閉じる',
          onPressed: windowManager.close,
          isClose: true,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isClose = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isClose;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        hoverColor: isClose
            ? Colors.red.withValues(alpha: 0.8)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}
