/// 利用規約のバージョン管理（ADR-0065）。
///
/// アプリが同梱する規約（`assets/terms/terms-of-use.md`）の版数。ユーザーが
/// 同意した版数（`PrivacySettings.acceptedTermsVersion`）がこれより古い、
/// または未同意のとき、起動時に同意モーダルを表示する。
///
/// 規約を改定したら、docs/release.md の「利用規約の改定チェックリスト」に
/// 従って正本・同梱コピー・license.rtf を更新した上で、この値を 1 増やす。
/// 増やすと全ユーザーに再同意モーダルが表示される。
const int currentTermsVersion = 2;

/// 同梱している利用規約本文のアセットパス。
const String termsAssetPath = 'assets/terms/terms-of-use.md';
