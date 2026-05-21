/// ファイルパスと先頭バイト列から `flutter_highlight` の言語 ID を判定する
/// 純粋関数（ADR-0046）。
///
/// 判定順は以下:
/// 1. ファイル拡張子から [_extensionToLanguage] を引く
/// 2. ヒットしなければ shebang（`#!/...`）から [_shebangToLanguage] を引く
/// 3. それでもヒットしなければ null（呼び出し側はプレーンテキスト表示）
String? detectLanguage(String path, String head) {
  final extLang = _extensionToLanguage[_extensionOf(path)];
  if (extLang != null) return extLang;

  final shebangLang = _languageFromShebang(head);
  if (shebangLang != null) return shebangLang;

  // ファイル名そのもののマッピング（拡張子なしの定番）。
  final nameLang = _filenameToLanguage[_basenameOf(path).toLowerCase()];
  if (nameLang != null) return nameLang;

  return null;
}

/// 拡張子 → `flutter_highlight` 言語 ID のホワイトリスト。
///
/// `highlight` パッケージ（flutter_highlight が依存）は 100+ 言語をサポート
/// するが、Roola で使う頻度の高い主要言語に絞って列挙する。未知の拡張子は
/// プレーンテキスト表示にフォールバックする方針（ADR-0046 / Decision 5）。
const Map<String, String> _extensionToLanguage = {
  // Web 系
  'js': 'javascript',
  'mjs': 'javascript',
  'cjs': 'javascript',
  'jsx': 'javascript',
  'ts': 'typescript',
  'tsx': 'typescript',
  'html': 'xml',
  'htm': 'xml',
  'xml': 'xml',
  'svg': 'xml',
  'css': 'css',
  'scss': 'scss',
  'less': 'less',
  'json': 'json',
  // データ・設定
  'yaml': 'yaml',
  'yml': 'yaml',
  'toml': 'ini',
  'ini': 'ini',
  'conf': 'ini',
  'env': 'bash',
  // シェル
  'sh': 'bash',
  'bash': 'bash',
  'zsh': 'bash',
  'fish': 'bash',
  // ドキュメント
  'md': 'markdown',
  'markdown': 'markdown',
  // ネイティブ言語
  'dart': 'dart',
  'swift': 'swift',
  'kt': 'kotlin',
  'kts': 'kotlin',
  'java': 'java',
  'go': 'go',
  'rs': 'rust',
  'py': 'python',
  'rb': 'ruby',
  'php': 'php',
  'c': 'c',
  'h': 'c',
  'cc': 'cpp',
  'cpp': 'cpp',
  'cxx': 'cpp',
  'hpp': 'cpp',
  'm': 'objectivec',
  'mm': 'objectivec',
  'cs': 'cs',
  'lua': 'lua',
  'pl': 'perl',
  'r': 'r',
  'scala': 'scala',
  'sql': 'sql',
  'graphql': 'graphql',
  'gql': 'graphql',
  // ビルド・依存
  'gradle': 'gradle',
  'dockerfile': 'dockerfile',
  // データシリアライズ
  'proto': 'protobuf',
  // 設定スクリプト
  'tf': 'terraform',
  'hcl': 'terraform',
};

/// 拡張子なしのファイル名でも判定したいもの。
const Map<String, String> _filenameToLanguage = {
  'dockerfile': 'dockerfile',
  'makefile': 'makefile',
  '.gitignore': 'bash',
  '.gitattributes': 'bash',
  '.env': 'bash',
  '.bashrc': 'bash',
  '.zshrc': 'bash',
};

/// shebang 行から言語を判定する。先頭が `#!` で始まらない場合は null。
String? _languageFromShebang(String head) {
  if (!head.startsWith('#!')) return null;
  final firstLineEnd = head.indexOf('\n');
  final line = firstLineEnd == -1 ? head : head.substring(0, firstLineEnd);
  for (final entry in _shebangToLanguage.entries) {
    if (line.contains(entry.key)) return entry.value;
  }
  return null;
}

/// shebang 内に含まれる識別子 → 言語 ID。
const Map<String, String> _shebangToLanguage = {
  'bash': 'bash',
  'zsh': 'bash',
  'sh': 'bash',
  'fish': 'bash',
  'python': 'python',
  'ruby': 'ruby',
  'perl': 'perl',
  'node': 'javascript',
  'deno': 'typescript',
};

/// ファイルパスの拡張子（小文字、`.` 抜き）。拡張子がなければ空文字。
String _extensionOf(String path) {
  final basename = _basenameOf(path);
  final dotIndex = basename.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex == basename.length - 1) return '';
  return basename.substring(dotIndex + 1).toLowerCase();
}

String _basenameOf(String path) {
  final lastSlash = path.lastIndexOf('/');
  return lastSlash == -1 ? path : path.substring(lastSlash + 1);
}
