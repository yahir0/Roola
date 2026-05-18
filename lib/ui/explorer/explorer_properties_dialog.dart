import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roola/l10n/app_localizations.dart';

/// パスに対応するファイル / ディレクトリのプロパティをダイアログで表示する。
///
/// 名前 / 絶対パス / 種類 / サイズ（ファイル時のみ）/ 更新日時 /
/// アクセス日時 / status 変更日時 / mode を表示。
/// パスはコピーできるよう SelectableText で出す。
Future<void> showPropertiesDialog(BuildContext context, String path) async {
  final type = FileSystemEntity.typeSync(path);
  if (type == FileSystemEntityType.notFound) {
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.explorerPropertyPathNotFound(path))),
    );
    return;
  }
  final FileStat stat;
  switch (type) {
    case FileSystemEntityType.directory:
      stat = Directory(path).statSync();
    case FileSystemEntityType.file:
      stat = File(path).statSync();
    default:
      return;
  }
  final isDir = type == FileSystemEntityType.directory;
  await showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        title: Text(l10n.explorerPropertyTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PropRow(label: l10n.explorerPropertyName, value: _basenameOf(path)),
              _PropRow(label: l10n.explorerPropertyPath, value: path),
              _PropRow(
                label: l10n.explorerPropertyType,
                value: isDir
                    ? l10n.explorerPropertyTypeDirectory
                    : l10n.explorerPropertyTypeFile,
              ),
              if (!isDir)
                _PropRow(
                  label: l10n.explorerPropertySize,
                  value: _formatBytes(stat.size),
                ),
              _PropRow(
                label: l10n.explorerPropertyModified,
                value: _formatDate(stat.modified),
              ),
              _PropRow(
                label: l10n.explorerPropertyAccessed,
                value: _formatDate(stat.accessed),
              ),
              _PropRow(
                label: l10n.explorerPropertyChanged,
                value: _formatDate(stat.changed),
              ),
              _PropRow(
                label: l10n.explorerPropertyPermission,
                value: stat.modeString(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.buttonClose),
          ),
        ],
      );
    },
  );
}

class _PropRow extends StatelessWidget {
  const _PropRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

String _basenameOf(String path) {
  final normalized = path.endsWith('/') && path.length > 1
      ? path.substring(0, path.length - 1)
      : path;
  final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();
  return segments.isEmpty ? normalized : segments.last;
}

String _formatDate(DateTime dt) {
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${pad(dt.month)}-${pad(dt.day)} '
      '${pad(dt.hour)}:${pad(dt.minute)}:${pad(dt.second)}';
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
