/// Windows のターミナルで使用するシェルの選択肢。
enum WindowsShell {
  /// コマンドプロンプト（cmd.exe）。
  cmd,

  /// Windows PowerShell 5.x（powershell.exe）。すべての Windows に同梱。
  powershell,

  /// PowerShell 7+（pwsh.exe）。別途インストールが必要。
  pwsh,
}
