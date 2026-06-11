// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_activation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ウィンドウ再アクティブ化（key 化）の epoch カウンタ（ADR-0055）。
///
/// ネイティブの [MainFlutterWindow.becomeKey] が `roola/window` チャネルで
/// 送る `didBecomeKey` を受けるたびに [state] をインクリメントする。各ペイン
/// body はこの値を `ref.listen` し、変化を「ウィンドウが再アクティブ化された」
/// シグナルとして受け取り、自タブが `focusedTab` ならフォーカスを再要求する。
///
/// keepAlive にしてチャネルハンドラをアプリ存続中ずっと生かす（最初に
/// `ref.listen` するペイン body のマウントで生成され、以降破棄されない）。

@ProviderFor(WindowActivation)
final windowActivationProvider = WindowActivationProvider._();

/// ウィンドウ再アクティブ化（key 化）の epoch カウンタ（ADR-0055）。
///
/// ネイティブの [MainFlutterWindow.becomeKey] が `roola/window` チャネルで
/// 送る `didBecomeKey` を受けるたびに [state] をインクリメントする。各ペイン
/// body はこの値を `ref.listen` し、変化を「ウィンドウが再アクティブ化された」
/// シグナルとして受け取り、自タブが `focusedTab` ならフォーカスを再要求する。
///
/// keepAlive にしてチャネルハンドラをアプリ存続中ずっと生かす（最初に
/// `ref.listen` するペイン body のマウントで生成され、以降破棄されない）。
final class WindowActivationProvider
    extends $NotifierProvider<WindowActivation, int> {
  /// ウィンドウ再アクティブ化（key 化）の epoch カウンタ（ADR-0055）。
  ///
  /// ネイティブの [MainFlutterWindow.becomeKey] が `roola/window` チャネルで
  /// 送る `didBecomeKey` を受けるたびに [state] をインクリメントする。各ペイン
  /// body はこの値を `ref.listen` し、変化を「ウィンドウが再アクティブ化された」
  /// シグナルとして受け取り、自タブが `focusedTab` ならフォーカスを再要求する。
  ///
  /// keepAlive にしてチャネルハンドラをアプリ存続中ずっと生かす（最初に
  /// `ref.listen` するペイン body のマウントで生成され、以降破棄されない）。
  WindowActivationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowActivationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowActivationHash();

  @$internal
  @override
  WindowActivation create() => WindowActivation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$windowActivationHash() => r'a6679c94b47a8a4fbc999f7720cc76f37c665e49';

/// ウィンドウ再アクティブ化（key 化）の epoch カウンタ（ADR-0055）。
///
/// ネイティブの [MainFlutterWindow.becomeKey] が `roola/window` チャネルで
/// 送る `didBecomeKey` を受けるたびに [state] をインクリメントする。各ペイン
/// body はこの値を `ref.listen` し、変化を「ウィンドウが再アクティブ化された」
/// シグナルとして受け取り、自タブが `focusedTab` ならフォーカスを再要求する。
///
/// keepAlive にしてチャネルハンドラをアプリ存続中ずっと生かす（最初に
/// `ref.listen` するペイン body のマウントで生成され、以降破棄されない）。

abstract class _$WindowActivation extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
