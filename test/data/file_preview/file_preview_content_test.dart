import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/file_preview/file_preview_content.dart';

void main() {
  test('text / image / pdf は isPreviewable=true（ADR-0050）', () {
    expect(
      const FilePreviewContent.text(
        path: '/a.txt',
        content: 'x',
        language: null,
        isTruncated: false,
      ).isPreviewable,
      isTrue,
    );
    expect(
      const FilePreviewContent.image(path: '/a.png').isPreviewable,
      isTrue,
    );
    expect(const FilePreviewContent.pdf(path: '/a.pdf').isPreviewable, isTrue);
  });

  test('binary / tooLarge / failed は isPreviewable=false', () {
    expect(
      const FilePreviewContent.binary(path: '/a.bin').isPreviewable,
      isFalse,
    );
    expect(
      const FilePreviewContent.tooLarge(
        path: '/a.bin',
        sizeBytes: 99999999,
      ).isPreviewable,
      isFalse,
    );
    expect(
      const FilePreviewContent.failed(path: '/a', message: 'x').isPreviewable,
      isFalse,
    );
  });
}
