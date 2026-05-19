/// Polaris のアクセント色の選択肢（ADR-0038 D4）。
///
/// アクセントは常に 1 色のみ使う方針は変えず、その 1 色をユーザーが
/// 切り替えられるようにする。既定は暖色の [gold]。[iceBlue] は着想段階で
/// 検討した寒色アクセント。実際の色値は app 層（`AppTheme`）が解決する。
enum PolarisAccent { gold, iceBlue }
