import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/terminal_runner/windows_shell.dart';
import 'package:roola/data/terminal_settings/terminal_settings_repository_impl.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';
import 'package:roola/ui/common/polaris_toggle.dart';

/// Windows のデフォルトシェル選択セクション（Task 5.7）。
///
/// macOS では `Platform.isWindows` が false のため表示されない。
/// pwsh.exe の存在チェックを行い、未インストール時に警告を表示する（Task 5.8）。
class WindowsShellSection extends ConsumerWidget {
  const WindowsShellSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isWindows) {
      return const SizedBox.shrink();
    }
    final settings = ref.watch(terminalSettingsProvider);
    final shell = settings.value?.windowsShell ?? WindowsShell.powershell;

    return PolarisSettingsSection(
      label: 'ターミナル',
      description: 'Windows のターミナルタブで使用するシェルを選択します。',
      children: [
        PolarisToggle<WindowsShell>(
          segments: const [
            PolarisToggleSegment(
              value: WindowsShell.cmd,
              label: 'CMD',
            ),
            PolarisToggleSegment(
              value: WindowsShell.powershell,
              label: 'PowerShell 5',
            ),
            PolarisToggleSegment(
              value: WindowsShell.pwsh,
              label: 'PowerShell 7',
            ),
          ],
          selected: shell,
          onChanged: settings.isLoading
              ? null
              : (value) =>
                    ref.read(terminalSettingsProvider.notifier).setWindowsShell(value),
        ),
        if (shell == WindowsShell.pwsh) const _PwshWarning(),
      ],
    );
  }
}

/// pwsh.exe の存在をチェックし、未インストール時に警告を表示する（Task 5.8）。
class _PwshWarning extends StatelessWidget {
  const _PwshWarning();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPwshAvailable(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        if (snap.data == true) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'pwsh.exe が見つかりません。PowerShell 7 をインストールしてください。\n'
            'https://github.com/PowerShell/PowerShell/releases',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  static Future<bool> _checkPwshAvailable() async {
    try {
      final result = await Process.run('pwsh', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
