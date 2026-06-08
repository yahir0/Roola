import 'dart:developer' as developer;

/// ノートパッドに保存された 1 件のメモ。
///
/// [folderId] が null のとき「未分類」扱い。永続化は [NotepadCatalogStore]
/// に委譲する。
class NotepadNote {
  const NotepadNote({
    required this.id,
    required this.title,
    required this.content,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotepadNote copyWith({
    String? id,
    String? title,
    String? content,
    Object? folderId = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotepadNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: identical(folderId, _sentinel) ? this.folderId : folderId as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    if (folderId != null) 'folderId': folderId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static NotepadNote? fromJson(Map<String, dynamic> json) {
    try {
      final now = DateTime.now();
      return NotepadNote(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '無題',
        content: (json['content'] as String?) ?? '',
        folderId: json['folderId'] as String?,
        createdAt: json.containsKey('createdAt')
            ? DateTime.parse(json['createdAt'] as String)
            : now,
        updatedAt: json.containsKey('updatedAt')
            ? DateTime.parse(json['updatedAt'] as String)
            : now,
      );
    } on Object catch (e) {
      developer.log('NotepadNote.fromJson failed: $e', name: 'NotepadNote');
      return null;
    }
  }
}

const _sentinel = Object();
