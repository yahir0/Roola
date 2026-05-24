import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'window_activation_provider.g.dart';

/// ウィンドウ再アクティブ化（key 化）の epoch カウンタ（ADR-0055）。
///
/// ネイティブの [MainFlutterWindow.becomeKey] が `roola/window` チャネルで
/// 送る `didBecomeKey` を受けるたびに [state] をインクリメントする。各ペイン
/// body はこの値を `ref.listen` し、変化を「ウィンドウが再アクティブ化された」
/// シグナルとして受け取り、自タブが `focusedTab` ならフォーカスを再要求する。
///
/// keepAlive にしてチャネルハンドラをアプリ存続中ずっと生かす（最初に
/// `ref.listen` するペイン body のマウントで生成され、以降破棄されない）。
@Riverpod(keepAlive: true)
class WindowActivation extends _$WindowActivation {
  static const _channel = MethodChannel('roola/window');

  @override
  int build() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'didBecomeKey') {
        state = state + 1;
      }
      return null;
    });
    ref.onDispose(() => _channel.setMethodCallHandler(null));
    return 0;
  }
}
