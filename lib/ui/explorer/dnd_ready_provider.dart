import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// OS 連携 DnD（`super_drag_and_drop` / ADR-0011）を有効化してよいかを表す
/// 起動フラグ（ADR-0049）。
///
/// 起動直後は `false`。初回フレーム描画後に [DndReadyNotifier.markReady] で
/// `true` になる。`DropRegion` / `DragItemWidget` などの
/// super_native_extensions 系 Widget は、このフラグが `true` になってから
/// マウントすること。
///
/// 背景: 起動直後にこれらを登録すると、ネイティブ側の
/// `irondash_engine_context` が保持する engine handle → FlutterView の
/// レジストリがまだ確定しておらず、`getFlutterView:` が解放済み／不正な
/// エントリを掴んで `objc_loadWeakRetained` でクラッシュすることがある
/// （間欠的な起動時 SIGSEGV）。初回フレーム後まで登録を遅らせ、レジストリ
/// 確定後に DnD を有効化することで競合の窓を塞ぐ。詳細は ADR-0049。
class DndReadyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// DnD を有効化する。冪等（既に有効なら何もしない）。
  void markReady() {
    if (!state) {
      state = true;
    }
  }
}

final dndReadyProvider = NotifierProvider<DndReadyNotifier, bool>(
  DndReadyNotifier.new,
);

/// 初回フレーム描画後に [dndReadyProvider] を有効化する初期化ゲート
/// （ADR-0049）。
///
/// アプリ最上位の Widget ツリーに 1 つだけ配置する。[child] はそのまま
/// 描画し、`addPostFrameCallback` で最初のフレーム完了後に DnD を有効化
/// する。これにより `DropRegion` 等の登録が engine/view レジストリ確定後
/// にずれ、起動時クラッシュの競合窓を避ける。
class DndReadyGate extends ConsumerStatefulWidget {
  const DndReadyGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DndReadyGate> createState() => _DndReadyGateState();
}

class _DndReadyGateState extends ConsumerState<DndReadyGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dndReadyProvider.notifier).markReady();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
