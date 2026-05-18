import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/notepad/notepad_repository.dart';
import 'package:roola/data/notepad/notepad_repository_impl.dart';

/// ノートパッド本文の単一の真実（ADR-0036）。
///
/// state はパネルに表示される本文そのもの。パネルを閉じても破棄されず、
/// 再度開いたときに最後の本文を復元するためのインメモリ保持を兼ねる
/// （`NotifierProvider` は autoDispose ではないため listener が居なくても
/// 生き続ける）。
class NotepadViewModel extends Notifier<String> {
  /// 本文の永続化をまとめる debounce 間隔。連続入力中の書き込み過多を
  /// 避けるため、最後の変更からこの時間が経過したら保存する。
  static const Duration saveDebounce = Duration(milliseconds: 300);

  Timer? _saveTimer;
  bool _dirty = false;

  /// dispose 時の flush で `state` を参照すると Riverpod が例外を投げるため、
  /// 最新本文を別途保持しておく。
  String _latest = '';

  late NotepadRepository _repository;

  @override
  String build() {
    _repository = ref.read(notepadRepositoryProvider);
    ref.onDispose(_handleDispose);
    _latest = ref.read(notepadInitialContentProvider);
    return _latest;
  }

  /// 本文を更新し、debounce 後に永続化を予約する。
  void updateContent(String content) {
    if (state == content) {
      return;
    }
    state = content;
    _latest = content;
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDebounce, _flush);
  }

  /// 保留中の変更があれば即座に永続化する。
  void _flush() {
    _saveTimer?.cancel();
    if (!_dirty) {
      return;
    }
    _dirty = false;
    unawaited(_persist(_latest));
  }

  /// プロバイダ破棄時（アプリ終了 / invalidate）に未保存分を取りこぼさない。
  void _handleDispose() {
    _flush();
  }

  Future<void> _persist(String content) async {
    try {
      await _repository.save(content);
    } on Object {
      // 永続化失敗はアプリを落とすほどではない（ADR-0028 と同方針）。握り潰す。
    }
  }
}

/// ノートパッド本文の Provider。ヘッダのトグルとパネルが参照する。
final notepadProvider = NotifierProvider<NotepadViewModel, String>(
  NotepadViewModel.new,
);
