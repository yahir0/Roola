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
import 'package:roola/ui/common/polaris_dialog.dart';
import 'package:roola/ui/common/polaris_glyphs.dart';
import 'package:roola/ui/common/polaris_modal_shell.dart';
import 'package:roola/ui/common/polaris_settings_panel.dart';
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
    final tokens = PolarisTokens.of(context);
    final entriesState = ref.watch(launcherEntriesProvider);
    final foldersState = ref.watch(launcherFoldersProvider);
    return PolarisModalShell(
      title: l10n.launcherManagementTitle,
      actions: [
        IconButton(
          icon: PolarisGlyph.folderPlus(color: tokens.textDim),
          tooltip: l10n.launcherAddFolderTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: () => _addFolder(context, ref),
        ),
        IconButton(
          icon: PolarisGlyph.plus(color: tokens.textDim),
          tooltip: l10n.launcherAddEntryTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: () => const EntryNewRoute().push<void>(context),
        ),
      ],
      child: _buildBody(l10n, entriesState, foldersState),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    AsyncValue<List<LauncherEntry>> entriesState,
    AsyncValue<List<LauncherFolder>> foldersState,
  ) {
    if (entriesState.isLoading || foldersState.isLoading) {
      return const Center(
        child: SizedBox(width: 160, child: LinearProgressIndicator()),
      );
    }
    final entriesError = entriesState.error ?? foldersState.error;
    if (entriesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(PolarisTokens.space6),
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
    final tokens = PolarisTokens.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PolarisGlyph.grid(color: tokens.textFaint),
          const SizedBox(height: PolarisTokens.space4),
          Text(
            l10n.launcherEmptyPlaceholder,
            style: tokens.body.copyWith(color: tokens.textDim),
          ),
          const SizedBox(height: PolarisTokens.space4),
          FilledButton.icon(
            icon: PolarisGlyph.plus(
              color: tokens.onAccent,
              size: PolarisIconSize.small,
            ),
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
      padding: const EdgeInsets.symmetric(vertical: PolarisTokens.space2),
      children: [
        for (final folder in folders) ...[
          _FolderHeader(folder: folder),
          for (final entry in entries.where((e) => e.folderId == folder.id))
            _EntryTile(entry: entry),
          if (entries.where((e) => e.folderId == folder.id).isEmpty)
            const _EmptyFolderHint(),
          const _Hairline(),
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
        final tokens = PolarisTokens.of(context);
        final hover = candidate.isNotEmpty;
        return Container(
          color: hover
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          height: PolarisTokens.space7,
          padding: const EdgeInsets.only(
            left: PolarisTokens.space4,
            right: PolarisTokens.space1,
          ),
          child: Row(
            children: [
              PolarisTypeIcon(isDir: true, color: tokens.accent),
              const SizedBox(width: PolarisTokens.space3),
              Expanded(
                child: Text(
                  folder.name,
                  style: tokens.body.copyWith(color: tokens.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<_FolderAction>(
                tooltip: AppLocalizations.of(
                  context,
                ).launcherFolderOperationsTooltip,
                icon: PolarisGlyph.dots(color: tokens.textDim),
                // 既定の 48px ヒット領域を詰め、行を背高にしない。
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: PolarisTokens.space7,
                  minHeight: PolarisTokens.space7,
                ),
                iconSize: PolarisIconSize.standard,
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
          height: PolarisTokens.space7,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: PolarisTokens.space4),
          child: PolarisFieldLabel(l10n.unclassified),
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
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space8,
        PolarisTokens.space2,
        PolarisTokens.space4,
        PolarisTokens.space2,
      ),
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
      padding: const EdgeInsets.fromLTRB(
        PolarisTokens.space8,
        PolarisTokens.space2,
        PolarisTokens.space4,
        PolarisTokens.space2,
      ),
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
    final tokens = PolarisTokens.of(context);
    return LongPressDraggable<LauncherEntry>(
      data: entry,
      // ドラッグ中はカーソル位置に半透明のサムネイルを表示する。影は使わず
      // （ADR-0038 D3）、surfaceHi + 1px ボーダーの計器パネル調にする。
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.surfaceHi,
              border: Border.all(color: tokens.line),
              borderRadius: BorderRadius.circular(tokens.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PolarisTokens.space4,
                vertical: PolarisTokens.space2,
              ),
              child: Row(
                children: [
                  _ActionIcon(action: entry.action),
                  const SizedBox(width: PolarisTokens.space3),
                  Expanded(
                    child: Text(
                      entry.displayName,
                      style: tokens.body.copyWith(color: tokens.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
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
    final tokens = PolarisTokens.of(context);
    // 動作の種別はアイコンが運ぶため、テキストは名前＋作業ディレクトリの
    // 2 行に詰める（ADR-0038 の密度・引き算）。
    return InkWell(
      onTap: () => EntryEditRoute(entryId: entry.id).push<void>(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PolarisTokens.space4,
          PolarisTokens.space1,
          PolarisTokens.space1,
          PolarisTokens.space1,
        ),
        child: Row(
          children: [
            _ActionIcon(action: entry.action),
            const SizedBox(width: PolarisTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.displayName,
                    style: tokens.body.copyWith(color: tokens.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.workingDirectory,
                    style: tokens.mono.copyWith(color: tokens.textDim),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: PolarisTokens.space2),
            IconButton(
              icon: PolarisGlyph.trash(color: tokens.textDim),
              tooltip: l10n.launcherDeleteEntryTooltip,
              visualDensity: VisualDensity.compact,
              onPressed: () => _confirmDelete(context, ref, entry),
            ),
          ],
        ),
      ),
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

/// 動作タイプ別の小さな leading アイコン（ADR-0023 で _EntryIcon を廃止）。
class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.action});

  final LauncherAction action;

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    final glyph = switch (action) {
      OpenHereAction() => PolarisGlyph.prompt(
        color: tokens.textDim,
        size: PolarisIconSize.small,
      ),
      RunCommandAction() => PolarisGlyph.bolt(
        color: tokens.textDim,
        size: PolarisIconSize.small,
      ),
      ClaudeSkillAction() => PolarisGlyph.sparkle(
        color: tokens.textDim,
        size: PolarisIconSize.small,
      ),
    };
    return Container(
      width: PolarisTokens.space7,
      height: PolarisTokens.space7,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.surfaceHi,
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      child: glyph,
    );
  }
}

/// セクション間の 1px ヘアライン区切り（Polaris / ADR-0038 D3）。
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    final tokens = PolarisTokens.of(context);
    return SizedBox(height: 1, child: ColoredBox(color: tokens.line));
  }
}
