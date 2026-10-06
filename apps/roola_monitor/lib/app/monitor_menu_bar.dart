import 'package:flutter/material.dart';

/// Roola Monitor の macOS メニューバー（ADR-0069 D7）。
///
/// アプリ名メニューは OS 標準の項目（About・サービス・隠す・終了）に、ライセンス
/// 一覧を開く項目を 1 つだけ足す。About は macOS 標準の About パネル（名前・
/// バージョン・アイコン・著作権を Info.plist から表示）を使う。
class MonitorMenuBar extends StatelessWidget {
  const MonitorMenuBar({
    required this.navigatorKey,
    required this.child,
    super.key,
  });

  /// ライセンス一覧を push する Navigator。
  final GlobalKey<NavigatorState> navigatorKey;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ja = Localizations.localeOf(context).languageCode == 'ja';
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'Roola Monitor',
          menus: [
            PlatformMenuItemGroup(
              members: [
                const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.about,
                ),
                PlatformMenuItem(
                  label: ja ? 'ライセンス…' : 'Licenses…',
                  onSelected: _showLicenses,
                ),
              ],
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.servicesSubmenu,
                ),
              ],
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hide,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hideOtherApplications,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.showAllApplications,
                ),
              ],
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit,
                ),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: ja ? 'ウインドウ' : 'Window',
          menus: const [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.minimizeWindow,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.zoomWindow,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.toggleFullScreen,
            ),
          ],
        ),
      ],
      child: child,
    );
  }

  /// 同梱 OSS（計器書体の SIL OFL を含む）のライセンス一覧を開く。
  /// ウィンドウはタイトルバーを残しているため、標準の [LicensePage] の戻る
  /// ボタンが信号灯と重ならない（Roola と違い自前の一覧は要らない）。
  void _showLicenses() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    showLicensePage(
      context: context,
      applicationName: 'Roola Monitor',
      applicationIcon: const SizedBox.shrink(),
    );
  }
}
