import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/core/constants/terms.dart';

/// 同梱アセットの利用規約本文（表示用に整形済み）。
///
/// 正本は Markdown（`docs/terms-of-use.md` のコピー）だが、アプリ内では
/// Markdown レンダラを持たないプレーン表示にする（ADR-0065）。見出し記号
/// `#` を落とし、箇条書き `-` を `・` に置き換えるだけの最小整形。
final termsTextProvider = FutureProvider<String>((ref) async {
  final raw = await rootBundle.loadString(termsAssetPath);
  return raw
      .split('\n')
      .map(
        (line) => line
            .replaceFirst(RegExp(r'^#{1,3} '), '')
            .replaceFirst(RegExp(r'^- '), '・'),
      )
      .join('\n');
});

/// 利用規約全文のスクロール表示。
///
/// 同意モーダル（`TermsConsentModal`）と設定からの閲覧（`TermsPage`）で
/// 共用する。規約の正文は日本語（第14条）のため、UI ロケールによらず
/// 本文は日本語のまま表示する。選択・コピーは可能にする。
class TermsTextView extends ConsumerWidget {
  const TermsTextView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terms = ref.watch(termsTextProvider);
    return terms.when(
      loading: () => const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, _) => Center(child: Text('$e')),
      data: (text) => Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: PolarisTokens.space6,
            vertical: PolarisTokens.space4,
          ),
          child: SelectionArea(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ),
    );
  }
}
