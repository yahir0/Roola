import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/data/repo_explorer/explorer_directory_loader.dart';
import 'package:roola/data/repo_explorer/explorer_node.dart';

/// サイドバーのお気に入りツリーが参照する「指定パス直下のサブディレクトリ
/// 一覧」を返す Provider。
///
/// 既存の [ExplorerDirectoryLoader] を流用してパス直下の listing を取得し、
/// **ディレクトリのみ** をフィルタする（ファイルはサイドバーには出さない）。
/// 並び順はローダーが返す名前昇順（大文字小文字無視）を踏襲する。
///
/// `autoDispose` のため、サイドバーで該当パスを畳むと listener が居なくなり
/// 自動的に破棄される。再展開時に最新の listing を読み直す（FSEvents 監視は
/// 掛けない: サイドバーのツリーは navigation 補助で、本体 Explorer ほど
/// realtime 反映の要請が無いため）。
///
/// パスが存在しない / 読めない場合はローダーが空リストを返すため、Provider
/// も空リストを返す。
final favoriteTreeChildrenProvider = Provider.autoDispose
    .family<List<ExplorerDirectoryNode>, String>((ref, path) {
      const loader = ExplorerDirectoryLoader();
      return loader
          .load(path)
          .whereType<ExplorerDirectoryNode>()
          .toList(growable: false);
    });
