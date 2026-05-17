import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/data/terminal_runner/terminal_channel.dart';

/// `TerminalChannel` の Dart 側ロジックを検証する。
///
/// SwiftTerm（ネイティブ）との実通信は実機確認の範囲（ADR-0031）。本テストは
/// バッファリング（プラットフォームビュー生成前の出力保持）と、ネイティブ →
/// Dart 受信ハンドラの配線をプラットフォームチャネルのモックで確認する。
TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const id = 'test-tab';
  const dataChannelName = 'roola/terminal/$id';
  const ctrlChannelName = 'roola/terminal/$id/ctrl';

  late TerminalChannel channel;
  late List<List<int>> sentToNative;

  setUp(() {
    sentToNative = [];
    channel = TerminalChannel(id);
    // Dart → native（feed）の送信を捕捉する。
    _messenger.setMockMessageHandler(dataChannelName, (message) async {
      if (message != null) {
        sentToNative.add(
          message.buffer
              .asUint8List(message.offsetInBytes, message.lengthInBytes)
              .toList(),
        );
      }
      return null;
    });
  });

  tearDown(() {
    channel.dispose();
    _messenger.setMockMessageHandler(dataChannelName, null);
  });

  group('feed のバッファリング', () {
    test('markReady 前の feed はバッファされ、送信されない', () async {
      channel.feed(Uint8List.fromList([1, 2]));
      channel.feed(Uint8List.fromList([3, 4]));
      await pumpEventQueue();

      expect(sentToNative, isEmpty);
    });

    test('markReady でバッファが投入順どおり flush される', () async {
      channel.feed(Uint8List.fromList([1, 2]));
      channel.feed(Uint8List.fromList([3, 4]));
      channel.markReady();
      await pumpEventQueue();

      expect(sentToNative, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('markReady 後の feed は即時送信される', () async {
      channel.markReady();
      channel.feed(Uint8List.fromList([9]));
      await pumpEventQueue();

      expect(sentToNative, [
        [9],
      ]);
    });
  });

  group('native → Dart 受信', () {
    test('データチャネル受信で onInput が呼ばれる', () async {
      Uint8List? received;
      channel.onInput = (data) => received = data;

      await _push(
        dataChannelName,
        ByteData.sublistView(Uint8List.fromList([7, 8, 9])),
      );

      expect(received?.toList(), [7, 8, 9]);
    });

    test('ctrl チャネルの resize で onResize が呼ばれる', () async {
      int? cols;
      int? rows;
      channel.onResize = (c, r) {
        cols = c;
        rows = r;
      };

      await _push(
        ctrlChannelName,
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('resize', {'cols': 100, 'rows': 30}),
        ),
      );

      expect(cols, 100);
      expect(rows, 30);
    });
  });

  test('dispose 後はネイティブ受信で onInput が呼ばれない', () async {
    var called = false;
    channel.onInput = (_) => called = true;
    channel.dispose();

    await _push(dataChannelName, ByteData.sublistView(Uint8List.fromList([1])));

    expect(called, isFalse);
  });
}

/// ネイティブからの受信メッセージを `channelBuffers` 経由で配送する。
Future<void> _push(String channel, ByteData message) async {
  ServicesBinding.instance.channelBuffers.push(channel, message, (_) {});
  await pumpEventQueue();
}
