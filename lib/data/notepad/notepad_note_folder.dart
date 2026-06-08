import 'dart:developer' as developer;

/// ノートパッドのメモをグループ化するフォルダ。
///
/// ネストは 1 階層のみ（ランチャーフォルダと同方針）。
class NotepadNoteFolder {
  const NotepadNoteFolder({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  NotepadNoteFolder copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return NotepadNoteFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  static NotepadNoteFolder? fromJson(Map<String, dynamic> json) {
    try {
      return NotepadNoteFolder(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: json.containsKey('createdAt')
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
    } on Object catch (e) {
      developer.log(
        'NotepadNoteFolder.fromJson failed: $e',
        name: 'NotepadNoteFolder',
      );
      return null;
    }
  }
}
