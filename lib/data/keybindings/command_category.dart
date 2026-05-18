/// コマンドの分類。設定画面のグルーピングとメニューバーのメニュー分けに使う。
enum CommandCategory {
  navigation('ナビゲーション'),
  explorer('エクスプローラ'),
  tab('タブ / ペイン'),
  app('ランチャー / アプリ'),
  git('Git');

  const CommandCategory(this.label);

  /// 設定画面の見出しに使う日本語ラベル。
  final String label;
}
