import 'package:flutter/services.dart';

/// SwiftTerm（ネイティブ macOS NSView）と Dart の間でターミナルのバイト列を
/// やり取りするブリッジ（ADR-0031）。タブ（PTY セッション）ごとに 1 インスタンス。
///
/// チャネルは 2 本:
///
/// - `roola/terminal/<id>`（[BasicMessageChannel] + [BinaryCodec]）— ターミナル
///   のバイト列を双方向に直送する。Dart→native は PTY 出力、native→Dart は
///   ユーザー入力。バイト列をそのまま運ぶため base64 等の追加エンコードは不要
/// - `roola/terminal/<id>/ctrl`（[MethodChannel]）— 構造化された制御メッセージ。
///   native→Dart の `resize` と、Dart→native の `focusTerminal`（ADR-0037）
///
/// プラットフォームビュー（`AppKitView`）の生成完了前に届いた PTY 出力は
/// [markReady] が呼ばれるまでバッファし、生成後にまとめて flush する。
class TerminalChannel {
  TerminalChannel(this.id)
    : _data = BasicMessageChannel<ByteData?>(
        'roola/terminal/$id',
        const BinaryCodec(),
      ),
      _ctrl = MethodChannel('roola/terminal/$id/ctrl') {
    _data.setMessageHandler(_handleNativeData);
    _ctrl.setMethodCallHandler(_handleNativeCtrl);
  }

  /// タブ固有のチャネル id（ad-hoc セッション id）。
  final String id;

  final BasicMessageChannel<ByteData?> _data;
  final MethodChannel _ctrl;

  /// SwiftTerm からのユーザー入力バイト列を受け取るコールバック。
  void Function(Uint8List data)? onInput;

  /// SwiftTerm からの端末サイズ変更を受け取るコールバック（cols, rows）。
  void Function(int cols, int rows)? onResize;

  bool _ready = false;
  final List<ByteData> _pending = [];

  /// プラットフォームビューの生成完了後に呼ぶ。バッファ済みの PTY 出力を
  /// native へ flush し、以降は [feed] を即時送信に切り替える。
  void markReady() {
    if (_ready) {
      return;
    }
    _ready = true;
    for (final chunk in _pending) {
      _data.send(chunk);
    }
    _pending.clear();
  }

  /// PTY 出力バイト列を SwiftTerm へ送る。ready 前はバッファする。
  void feed(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    if (!_ready) {
      _pending.add(data);
      return;
    }
    _data.send(data);
  }

  /// SwiftTerm のネイティブビューをウインドウの first responder にするよう
  /// native へ要求する。Flutter 側でターミナル面がフォーカスを得たときに
  /// 呼び、ネイティブのキー入力先と Flutter のフォーカスを一致させる
  /// （ADR-0037）。
  void requestNativeFocus() {
    _ctrl.invokeMethod<void>('focusTerminal');
  }

  Future<ByteData?> _handleNativeData(ByteData? message) async {
    if (message != null) {
      onInput?.call(
        message.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ),
      );
    }
    return null;
  }

  Future<dynamic> _handleNativeCtrl(MethodCall call) async {
    if (call.method == 'resize') {
      final args = (call.arguments as Map).cast<String, dynamic>();
      onResize?.call(args['cols'] as int, args['rows'] as int);
    }
    return null;
  }

  /// チャネルのハンドラを解除し、バッファとコールバックを解放する。
  void dispose() {
    _data.setMessageHandler(null);
    _ctrl.setMethodCallHandler(null);
    _pending.clear();
    onInput = null;
    onResize = null;
  }
}
