import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:roola/app/router.dart';
import 'package:roola/app/theme.dart';
import 'package:roola/data/launcher_entry/launcher_action.dart';
import 'package:roola/data/launcher_entry/launcher_entries_provider.dart';
import 'package:roola/data/launcher_entry/launcher_entry.dart';
import 'package:roola/data/launcher_entry/launcher_folder.dart';
import 'package:roola/data/launcher_entry/launcher_folders_provider.dart';
import 'package:roola/l10n/app_localizations.dart';
import 'package:roola/ui/common/macos_window_app_bar.dart';
import 'package:roola/ui/common/polaris_dialog.dart';
import 'package:roola/ui/common/prompt_name_dialog.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 登録済みランチャーエントリの管理画面。
///
/// 旧来は SettingsPage に混在していたが、エントリ一覧は「アプリ設定」ではなく
/// 「コンテンツ管理」なので独立画面に分離した（ADR-0018）。サイドバーの
/// ランチャーセクション末尾の「管理…」ボタンから push される。
///
/// 一覧表示・追加導線・削除確認・フォルダ管理（追加 / リネーム / 削除）に加え、
/// エントリのドラッグ&ドロップでフォルダ間移動も提供（ADR-0019 Phase 3）。
/// エントリの編集自体は ListTile タップで [EntryEditRoute] へ遷移。
class LauncherManagementPage extends ConsumerWidget {
  const LauncherManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entriesState = ref.watch(launcherEntriesProvider);
    final foldersState = ref.watch(launcherFoldersProvider);
    return Scaffold(
      appBar: MacosWindowAppBar(
        title: Text(l10n.launcherManagementTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: l10n.launcherAddFolderTooltip,
            onPressed: () => _addFolder(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.launcherAddEntryTooltip,
            onPressed: () => const EntryNewRoute().push<void>(context),
          ),
        ],
      ),
      body: _buildBody(l10n, entriesState, foldersState),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    AsyncValue<List<LauncherEntry>> entriesState,
    AsyncValue<List<LauncherFolder>> foldersState,
  ) {
    if (entriesState.isLoading || foldersState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final entriesError = entriesState.error ?? foldersState.error;
    if (entriesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.launcherLoadError('$entriesError')),
        ),
      );
    }
    final entries = entriesState.value ?? const [];
    final folders = foldersState.value ?? const [];
    if (entries.isEmpty && folders.isEmpty) {
      return const _EmptyPlaceholder();
    }
    return _Catalog(entries: entries, folders: folders);
  }

  Future<void> _addFolder(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await promptName(
      context,
      title: l10n.launcherFolderNameTitle,
      hintText: l10n.launcherFolderNameHint,
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    await ref
        .read(launcherFoldersProvider.notifier)
        .add(
          LauncherFolder(
            id: _uuid.v4(),
            name: name.trim(),
            createdAt: DateTime.now(),
          ),
        );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard_customize, size: PolarisIconSize.hero),
          const SizedBox(height: 16),
          Text(l10n.launcherEmptyPlaceholder),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.launcherAddEntryButton),
            onPressed: () => const EntryNewRoute().push<void>(context),
          ),
        ],
      ),
    );
  }
}

/// フォルダごとにエントリをグループ化した一覧表示。
///
/// 上から: 各フォルダ（ヘッダ + 中身のエントリ）→ 未分類（root）エントリ。
/// フォルダの中身は管理画面では常に展開して見せる（サイドバーと違い、ここは
/// 編集用途なので折り畳まない）。
///
/// ドラッグ&ドロップ動線:
/// - エントリは [LongPressDraggable]<[LauncherEntry]> で長押しドラッグ可能
/// - フォルダヘッダ / 「未分類」ヘッダは [DragTarget]<[LauncherEntry]> で
///   受け取り、`folderId` を切り替えて `updateEntry` する
/// - フォルダが 1 つでも存在する場合は root セクションも常時表示し、空でも
///   ドロップ可能（フォルダ → root への戻し動線を確保）
class _Catalog extends ConsumerWidget {
  const _Catalog({required this.entries, required this.folders});

  final List<LauncherEntry> entries;
  final List<LauncherFolder> folders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootEntries = entries.where((e) => e.folderId == null).toList();
    final showRootSection = folders.isNotEmpty || rootEntries.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final folder in folders) ...[
          _FolderHeader(folder: folder),
          for (final entry in entries.where((e) => e.folderId == folder.id))
            _EntryTile(entry: entry),
          if (entries.where((e) => e.folderId == folder.id).isEmpty)
            const _EmptyFolderHint(),
          const Divider(height: 1),
        ],
        if (showRootSection) ...[
          if (folders.isNotEmpty) const _RootSectionHeader(),
          for (final entry in rootEntries) _EntryTile(entry: entry),
          if (folders.isNotEmpty && rootEntries.isEmpty) const _EmptyRootHint(),
        ],
      ],
    );
  }
}

/// フォルダ 1 件分のヘッダ。DragTarget でエントリを受け取り、配下に移動する。
class _FolderHeader extends ConsumerWidget {
  const _FolderHeader({required this.folder});

  final LauncherFolder folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return DragTarget<LauncherEntry>(
      // 既に自フォルダにいるエントリは accept しない（無駄な save 防止）。
      onWillAcceptWithDetails: (details) => details.data.folderId != folder.id,
      onAcceptWithDetails: (details) async {
        await ref
            .read(launcherEntriesProvider.notifier)
            .updateEntry(details.data.copyWith(folderId: folder.id));
      },
      builder: (context, candidate, rejected) {
        final hover = candidate.isNotEmpty;
        return Container(
          color: hover
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: PolarisIconSize.standard,
                color: colors.secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  folder.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuButton<_FolderAction>(
                tooltip: AppLocalizations.of(
                  context,
                ).launcherFolderOperationsTooltip,
                icon: const Icon(Icons.more_horiz),
                onSelected: (action) => _onAction(context, ref, action),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _FolderAction.rename,
                    child: Text(AppLocalizations.of(context).buttonRename),
                  ),
                  PopupMenuItem(
                    value: _FolderAction.delete,
                    child: Text(l10n.folderDeleteWithContentsMenuItem),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _FolderAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case _FolderAction.rename:
        final newName = await promptName(
          context,
          title: l10n.launcherFolderNameTitle,
          initialValue: folder.name,
        );
        if (newName == null || newName.trim().isEmpty) {
          return;
        }
        await ref
            .read(launcherFoldersProvider.notifier)
            .updateFolder(folder.copyWith(name: newName.trim()));
      case _FolderAction.delete:
        if (!context.mounted) {
          return;
        }
        final confirmed = await showPolarisConfirm(
          context,
          title: l10n.folderDeleteConfirmTitle,
          message: l10n.folderDeleteConfirmMessage(folder.name),
          confirmLabel: l10n.buttonDelete,
          cancelLabel: l10n.buttonCancel,
          destructive: true,
        );
        if (confirmed) {
          await ref.read(launcherFoldersProvider.notifier).delete(folder.id);
        }
    }
  }
}

enum _FolderAction { rename, delete }

/// 「未分類」（root）セクションのヘッダ。DragTarget でエントリを受け取り、
/// folderId を null に戻す。フォルダ → root への戻し動線。
class _RootSectionHeader extends ConsumerWidget {
  const _RootSectionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return DragTarget<LauncherEntry>(
      // 既に root にいるエントリは accept しない。
      onWillAcceptWithDetails: (details) => details.data.folderId != null,
      onAcceptWithDetails: (details) async {
        await ref
            .read(launcherEntriesProvider.notifier)
            .updateEntry(details.data.copyWith(folderId: null));
      },
      builder: (context, candidate, rejected) {
        final hover = candidate.isNotEmpty;
        return Container(
          color: hover
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            l10n.unclassified,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyFolderHint extends StatelessWidget {
  const _EmptyFolderHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 16, 8),
      child: Text(
        l10n.launcherEmptyFolderHint,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _EmptyRootHint extends StatelessWidget {
  const _EmptyRootHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 16, 8),
      child: Text(
        l10n.launcherEmptyRootHint,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

/// エントリ 1 件分のタイル。LongPressDraggable でドラッグ可能（ADR-0019）。
class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});

  final LauncherEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = PolarisTokens.of(context);
    return LongPressDraggable<LauncherEntry>(
      data: entry,
      // ドラッグ中はカーソル位置に半透明のサムネイルを表示する。Material
      // 包装が必要なのは elevation / overlay 由来。
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(tokens.radius),
        child: SizedBox(
          width: 320,
          child: ListTile(
            leading: _ActionIcon(action: entry.action),
            title: Text(entry.displayName),
            subtitle: Text(_actionLabel(l10n, entry.action), maxLines: 1),
          ),
        ),
      ),
      // 元位置はうっすら残してプレビュー扱いにする。
      childWhenDragging: Opacity(opacity: 0.4, child: _content(context, ref)),
      child: _content(context, ref),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: _ActionIcon(action: entry.action),
      title: Text(entry.displayName),
      subtitle: Text(
        '${entry.workingDirectory}\n${_actionLabel(l10n, entry.action)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: l10n.launcherDeleteEntryTooltip,
        onPressed: () => _confirmDelete(context, ref, entry),
      ),
      onTap: () => EntryEditRoute(entryId: entry.id).push<void>(context),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LauncherEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showPolarisConfirm(
      context,
      title: l10n.launcherDeleteEntryConfirm,
      message: l10n.launcherDeleteEntryMessage(entry.displayName),
      confirmLabel: l10n.buttonDelete,
      cancelLabel: l10n.buttonCancel,
      destructive: true,
    );
    if (confirmed) {
      await ref.read(launcherEntriesProvider.notifier).delete(entry.id);
    }
  }
}

/// subtitle に表示する 1 行分の動作説明。
String _actionLabel(AppLocalizations l10n, LauncherAction action) =>
    switch (action) {
      OpenHereAction() => l10n.launcherActionLabelOpenHere,
      RunCommandAction(:final command) => l10n.launcherActionLabelRunCommand(
        command,
      ),
      ClaudeSkillAction(:final skillName) =>
        l10n.launcherActionLabelClaudeSkill(skillName),
    };

/// 動作タイプ別の小さな leading アイコン（ADR-0023 で _EntryIcon を廃止）。
class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.action});

  final LauncherAction action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tokens = PolarisTokens.of(context);
    final icon = switch (action) {
      OpenHereAction() => Icons.folder_open,
      RunCommandAction() => Icons.bolt,
      ClaudeSkillAction() => Icons.auto_awesome,
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: Icon(
        icon,
        size: PolarisIconSize.standard,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
