import 'dart:async';
import 'dart:io';

/// 指定ディレクトリのファイルシステム変更をデバウンス付きで通知する薄い
/// ラッパ（ADR-0041）。
///
/// `Directory.watch()` は macOS では FSEvents を使うので低コスト。発生
/// イベントの詳細（種類・パス）は捨て、「何かが変わった」だけを単一の
/// `void` イベントとして流す。連続イベントは [debounce] 内に最後の 1 件に
/// まとめる。
///
/// 監視中のディレクトリが消えた / 権限が無い等で `Directory.watch()` が
/// 例外を発生させた場合は、購読をそのまま閉じる（呼び出し側は再 listen で
/// 復旧を試みても良いし、無視しても良い）。
class DirectoryWatcher {
  const DirectoryWatcher();

  /// [path] 配下を監視し、デバウンスされた変更通知の Stream を返す。
  ///
  /// [recursive] が true ならサブディレクトリも含めて監視する（FSEvents の
  /// 再帰モード）。[exclude] を渡すと、変更が起きたパス（[path] からの相対
  /// パス、`/` 始まりでない）に対して true を返すイベントを捨てる。
  /// [debounce] は連続イベントをまとめる猶予時間。
  ///
  /// 戻り値の Stream は購読時に `Directory.watch()` を開始し、購読解除時に
  /// 解放する single-subscription stream。
  Stream<void> watch(
    String path, {
    Duration debounce = const Duration(milliseconds: 300),
    bool recursive = false,
    bool Function(String relativePath)? exclude,
  }) {
    final controller = StreamController<void>();
    StreamSubscription<FileSystemEvent>? sub;
    Timer? timer;

    void emit() {
      timer?.cancel();
      timer = Timer(debounce, () {
        if (!controller.isClosed) {
          controller.add(null);
        }
      });
    }

    void start() {
      try {
        final dir = Directory(path);
        if (!dir.existsSync()) {
          controller.close();
          return;
        }
        sub = dir
            .watch(recursive: recursive)
            .listen(
              (event) {
                if (exclude != null) {
                  final rel = _relativize(path, event.path);
                  if (exclude(rel)) {
                    return;
                  }
                }
                emit();
              },
              onError: (Object _, StackTrace _) {
                // 監視ソースが死んだら無理せず Stream を閉じる。フォールバック
                // のポーリングは入れない（ADR-0041 / 失敗時の挙動）。
                controller.close();
              },
              cancelOnError: true,
            );
      } on FileSystemException {
        controller.close();
      }
    }

    controller.onListen = start;
    controller.onCancel = () async {
      timer?.cancel();
      await sub?.cancel();
      sub = null;
    };

    return controller.stream;
  }

  /// [base] を起点とした [target] の相対パスを返す。
  /// 監視ルート自身に対するイベント（target == base）は空文字を返す。
  /// `Directory.watch` が返す event.path は絶対パスで、base が prefix と
  /// 一致しない（シンボリックリンク経路等）ケースは event.path をそのまま
  /// 返す。
  static String _relativize(String base, String target) {
    if (target == base) {
      return '';
    }
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    if (target.startsWith(normalizedBase)) {
      return target.substring(normalizedBase.length);
    }
    return target;
  }
}
