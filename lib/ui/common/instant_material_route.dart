import 'package:flutter/material.dart';

/// 遷移時間を 0 にした [MaterialPageRoute]（ADR-0038 D7）。
///
/// 既定の [MaterialPageRoute] は [transitionDuration] が 300ms あり、その間は
/// 遷移前のルートも下に描画されたままになる。Polaris の各画面は `Scaffold` の
/// 背景を透明にして `_AppearanceLayer` の基底層へ描画を委ねているため、
/// 既定の duration では遷移中に基底層ではなく遷移前のルートが透けて見える。
/// Polaris は遷移を即時化する方針なので、duration を 0 にして遷移前ルートを
/// 1 フレーム内にツリーから外す。
class InstantMaterialRoute<T> extends MaterialPageRoute<T> {
  InstantMaterialRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;
}
