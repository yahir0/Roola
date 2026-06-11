import 'package:flutter/material.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/polaris_modal_shell.dart';
import 'package:roola/ui/consent/terms_text_view.dart';

/// 利用規約の閲覧ページ（`/terms`）。設定画面のプライバシーセクションから
/// 開く。同意モーダルと違い通常の [PolarisModalShell] なので閉じられる。
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PolarisModalShell(
      title: AppLocalizations.of(context).termsPageTitle,
      child: const TermsTextView(),
    );
  }
}
