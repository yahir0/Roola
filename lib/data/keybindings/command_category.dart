/// コマンドの分類。設定画面のグルーピングとメニューバーのメニュー分けに使う。
///
/// 表示ラベルはロケール依存のため enum 自体は持たず、UI 層が
/// `AppLocalizations` から解決する（ADR-0034）。
enum CommandCategory { navigation, explorer, tab, app, git }
