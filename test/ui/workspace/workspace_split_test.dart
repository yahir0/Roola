import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roola/ui/workspace/workspace_split.dart';

void main() {
  testWidgets('WorkspaceSplit は first / second の両方を描画する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceSplit(
            axis: Axis.horizontal,
            ratio: 0.5,
            onRatioChanged: (_) {},
            first: const Text('ペインA'),
            second: const Text('ペインB'),
          ),
        ),
      ),
    );
    expect(find.text('ペインA'), findsOneWidget);
    expect(find.text('ペインB'), findsOneWidget);
  });

  testWidgets('ハンドルのドラッグで onRatioChanged が呼ばれる', (tester) async {
    final ratios = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspaceSplit(
            axis: Axis.horizontal,
            ratio: 0.5,
            onRatioChanged: ratios.add,
            first: const Text('A'),
            second: const Text('B'),
          ),
        ),
      ),
    );
    // 既定テスト画面（800x600）で ratio=0.5 のハンドルは画面中央 x≈400。
    // そこを掴んで右へドラッグする。
    await tester.dragFrom(const Offset(400, 300), const Offset(40, 0));
    await tester.pump();
    expect(ratios, isNotEmpty);
    // 右へドラッグ → first 比率が増える。
    expect(ratios.last, greaterThan(0.5));
  });
}
