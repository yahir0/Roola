import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/notepad/notepad_catalog_store.dart';
import 'package:roola/data/notepad/notepad_note.dart';
import 'package:roola/data/notepad/notepad_note_folder.dart';

/// ノートパッドの保存済みメモ一覧の AsyncNotifier。
///
/// サイドバーの NOTEPAD セクションとタブ body から参照される。
class NotepadNotesNotifier extends AsyncNotifier<List<NotepadNote>> {
  NotepadCatalogStore get _store => ref.read(notepadCatalogStoreProvider);

  @override
  Future<List<NotepadNote>> build() async {
    final snapshot = await _store.load();
    return snapshot.notes;
  }

  Future<NotepadNote> addNote(NotepadNote note) async {
    state = const AsyncValue.loading();
    late NotepadNote saved;
    state = await AsyncValue.guard(() async {
      final snapshot = await _store.load();
      saved = note;
      await _store.save(
        NotepadCatalogSnapshot(
          folders: snapshot.folders,
          notes: [...snapshot.notes, note],
        ),
      );
      return [...snapshot.notes, note];
    });
    return saved;
  }

  Future<void> updateNote(NotepadNote note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final snapshot = await _store.load();
      final index = snapshot.notes.indexWhere((n) => n.id == note.id);
      if (index < 0) return snapshot.notes;
      final updated = [...snapshot.notes]..[index] = note;
      await _store.save(
        NotepadCatalogSnapshot(folders: snapshot.folders, notes: updated),
      );
      return updated;
    });
  }

  Future<void> deleteNote(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final snapshot = await _store.load();
      final filtered = snapshot.notes.where((n) => n.id != id).toList();
      await _store.save(
        NotepadCatalogSnapshot(folders: snapshot.folders, notes: filtered),
      );
      return filtered;
    });
  }

  /// フォルダを削除したとき、そのフォルダに属するメモを未分類に降格する。
  Future<void> unfoldNotes(String folderId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final snapshot = await _store.load();
      final updated = snapshot.notes
          .map((n) => n.folderId == folderId ? n.copyWith(folderId: null) : n)
          .toList();
      await _store.save(
        NotepadCatalogSnapshot(folders: snapshot.folders, notes: updated),
      );
      return updated;
    });
  }
}

final notepadNotesProvider =
    AsyncNotifierProvider<NotepadNotesNotifier, List<NotepadNote>>(
      NotepadNotesNotifier.new,
    );

/// ノートパッドのフォルダ一覧の AsyncNotifier。
class NotepadFoldersNotifier extends AsyncNotifier<List<NotepadNoteFolder>> {
  NotepadCatalogStore get _store => ref.read(notepadCatalogStoreProvider);

  @override
  Future<List<NotepadNoteFolder>> build() async {
    final snapshot = await _store.load();
    return snapshot.folders;
  }

  Future<void> addFolder(NotepadNoteFolder folder) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final snapshot = await _store.load();
      final updated = [...snapshot.folders, folder];
      await _store.save(
        NotepadCatalogSnapshot(folders: updated, notes: snapshot.notes),
      );
      return updated;
    });
  }

  Future<void> deleteFolder(String id) async {
    // 先にメモを未分類へ降格してからフォルダを削除する。
    await ref.read(notepadNotesProvider.notifier).unfoldNotes(id);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final snapshot = await _store.load();
      final filtered = snapshot.folders.where((f) => f.id != id).toList();
      await _store.save(
        NotepadCatalogSnapshot(folders: filtered, notes: snapshot.notes),
      );
      return filtered;
    });
  }
}

final notepadFoldersProvider =
    AsyncNotifierProvider<NotepadFoldersNotifier, List<NotepadNoteFolder>>(
      NotepadFoldersNotifier.new,
    );
