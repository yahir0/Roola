import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/notepad/notepad_repository.dart';

/// `<appSupport>/notepad.json` を保存先とする [NotepadRepository] 実装。
///
/// 本文は単一の文字列のため、`appearance` のような DTO ⇄ モデル分離は
/// 置かず、JSON（`{"content": "<text>"}`）と文字列をこのクラスで直接
/// 変換する（`locale_settings` と同方針）。
class NotepadRepositoryImpl implements NotepadRepository {
  NotepadRepositoryImpl({required this.paths});

  final AppPaths paths;

  /// JSON のキー名。
  static const String _contentKey = 'content';

  @override
  Future<String> load() async {
    final file = paths.notepadFile;
    if (!file.existsSync()) {
      return '';
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return '';
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return '';
      }
      final content = decoded[_contentKey];
      return content is String ? content : '';
    } on FormatException {
      return '';
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  @override
  Future<void> save(String content) async {
    await paths.ensureDirectories();
    try {
      await paths.notepadFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert({_contentKey: content}),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }
}

/// [NotepadRepository] の Provider。
final notepadRepositoryProvider = Provider<NotepadRepository>((ref) {
  return NotepadRepositoryImpl(paths: ref.watch(appPathsProvider));
});

/// 起動時に 1 度だけ読み込んだノートパッド本文の初期値。
///
/// パネルを最初に開いた瞬間に本文を即座に表示できるよう、`AsyncNotifier`
/// での遅延読み込みではなく `main()` で同期解決し、`overrideWithValue` で
/// 注入する（ワークスペースの ADR-0028 / 言語の ADR-0034 と同方式）。
final notepadInitialContentProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'notepadInitialContentProvider must be overridden in main()',
  );
});
