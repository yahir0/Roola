import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/core/exceptions/app_exception.dart';
import 'package:roola/core/storage/app_paths.dart';
import 'package:roola/data/launcher_entry/launcher_entry_repository_impl.dart';
import 'package:roola/data/notepad/notepad_note.dart';
import 'package:roola/data/notepad/notepad_note_folder.dart';

/// `<appSupport>/notepad_catalog.json` を 1 ファイルで読み書きする store。
///
/// スキーマ: `{"folders": [...], "notes": [...]}`.
/// LauncherCatalogStore と同方針。
class NotepadCatalogStore {
  NotepadCatalogStore({required this.paths});

  final AppPaths paths;

  Future<NotepadCatalogSnapshot> load() async {
    final file = paths.notepadCatalogFile;
    if (!file.existsSync()) {
      return const NotepadCatalogSnapshot(folders: [], notes: []);
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const NotepadCatalogSnapshot(folders: [], notes: []);
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const NotepadCatalogSnapshot(folders: [], notes: []);
      }
      final folders = _parseFolders(decoded['folders']);
      final notes = _parseNotes(decoded['notes']);
      return NotepadCatalogSnapshot(folders: folders, notes: notes);
    } on FormatException {
      return const NotepadCatalogSnapshot(folders: [], notes: []);
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  Future<void> save(NotepadCatalogSnapshot snapshot) async {
    await paths.ensureDirectories();
    final json = {
      'folders': snapshot.folders.map((f) => f.toJson()).toList(),
      'notes': snapshot.notes.map((n) => n.toJson()).toList(),
    };
    try {
      await paths.notepadCatalogFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
        flush: true,
      );
    } on FileSystemException catch (e) {
      throw AppException.persistenceFailure(e.message);
    }
  }

  List<NotepadNoteFolder> _parseFolders(dynamic raw) {
    if (raw is! List) return const [];
    final result = <NotepadNoteFolder>[];
    for (final item in raw.whereType<Map<String, dynamic>>()) {
      final folder = NotepadNoteFolder.fromJson(item);
      if (folder != null) result.add(folder);
    }
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }

  List<NotepadNote> _parseNotes(dynamic raw) {
    if (raw is! List) return const [];
    final result = <NotepadNote>[];
    for (final item in raw.whereType<Map<String, dynamic>>()) {
      final note = NotepadNote.fromJson(item);
      if (note != null) {
        result.add(note);
      } else {
        developer.log(
          'notepad note parse failed, skipping',
          name: 'NotepadCatalogStore',
        );
      }
    }
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }
}

class NotepadCatalogSnapshot {
  const NotepadCatalogSnapshot({
    required this.folders,
    required this.notes,
  });

  final List<NotepadNoteFolder> folders;
  final List<NotepadNote> notes;
}

/// `NotepadCatalogStore` の Provider。
final notepadCatalogStoreProvider = Provider<NotepadCatalogStore>((ref) {
  return NotepadCatalogStore(paths: ref.watch(appPathsProvider));
});
