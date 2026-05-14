import 'package:flutter_test/flutter_test.dart';
import 'package:roola/ui/explorer/launcher_actions.dart';

/// `generateUniqueDisplayName` の pure logic に対するテスト。
///
/// 「base」「base 2」「base 3」... の順で空きを探し、空き番号があれば
/// そこを埋める（Finder の同名ファイル命名と同じ）。
void main() {
  group('generateUniqueDisplayName', () {
    test('returns base when existing is empty', () {
      expect(generateUniqueDisplayName('foo', <String>{}), 'foo');
    });

    test('returns base when existing does not contain base', () {
      expect(generateUniqueDisplayName('foo', {'bar', 'baz'}), 'foo');
    });

    test('appends 2 when base is taken', () {
      expect(generateUniqueDisplayName('foo', {'foo'}), 'foo 2');
    });

    test('appends 3 when base and "base 2" are taken', () {
      expect(generateUniqueDisplayName('foo', {'foo', 'foo 2'}), 'foo 3');
    });

    test('fills the smallest gap when intermediate numbers are free', () {
      expect(generateUniqueDisplayName('foo', {'foo', 'foo 3'}), 'foo 2');
    });

    test('fills 3 when 1 (= base) and 2 are taken but 4 is free', () {
      expect(
        generateUniqueDisplayName('foo', {'foo', 'foo 2', 'foo 4'}),
        'foo 3',
      );
    });

    test('numbered base is treated literally (not parsed)', () {
      // base が "foo 2" の場合、それが空きなら "foo 2" を返す。
      expect(generateUniqueDisplayName('foo 2', {'foo'}), 'foo 2');
    });

    test('handles base containing spaces by treating it literally', () {
      expect(generateUniqueDisplayName('my skill', {'my skill'}), 'my skill 2');
    });
  });
}
