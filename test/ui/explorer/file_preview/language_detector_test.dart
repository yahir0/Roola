import 'package:flutter_test/flutter_test.dart';
import 'package:roola/ui/explorer/file_preview/language_detector.dart';

void main() {
  group('拡張子マッピング', () {
    test('.dart → dart', () {
      expect(detectLanguage('/tmp/foo.dart', ''), 'dart');
    });

    test('.ts → typescript', () {
      expect(detectLanguage('/tmp/foo.ts', ''), 'typescript');
    });

    test('.yml と .yaml → yaml', () {
      expect(detectLanguage('/tmp/a.yml', ''), 'yaml');
      expect(detectLanguage('/tmp/b.yaml', ''), 'yaml');
    });

    test('.md → markdown', () {
      expect(detectLanguage('/tmp/README.md', ''), 'markdown');
    });

    test('大文字拡張子も判定する', () {
      expect(detectLanguage('/tmp/foo.DART', ''), 'dart');
    });

    test('未知の拡張子は null', () {
      expect(detectLanguage('/tmp/foo.unknownext', ''), isNull);
    });
  });

  group('ファイル名マッピング（拡張子なし）', () {
    test('Dockerfile（拡張子なし）→ dockerfile', () {
      expect(detectLanguage('/repo/Dockerfile', ''), 'dockerfile');
    });

    test('Makefile → makefile', () {
      expect(detectLanguage('/repo/Makefile', ''), 'makefile');
    });

    test('.gitignore → bash', () {
      expect(detectLanguage('/repo/.gitignore', ''), 'bash');
    });
  });

  group('shebang フォールバック', () {
    test('#!/bin/bash → bash', () {
      expect(detectLanguage('/tmp/script', '#!/bin/bash\necho hi'), 'bash');
    });

    test('#!/usr/bin/env python3 → python', () {
      expect(
        detectLanguage('/tmp/run', '#!/usr/bin/env python3\nprint(1)'),
        'python',
      );
    });

    test('shebang でなければ null', () {
      expect(detectLanguage('/tmp/note', 'hello world'), isNull);
    });
  });

  test('拡張子マッピングが shebang より優先される', () {
    // .py 拡張子は python を返す。shebang が bash でも拡張子側を信用する。
    expect(detectLanguage('/tmp/foo.py', '#!/bin/bash\n'), 'python');
  });
}
