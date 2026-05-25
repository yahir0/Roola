import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

/// アプリ起動ごとに 1 度だけ生成する通知トークン（ADR-0057）。
///
/// `ClaudeSkillAction` の PTY に `ROOLA_NOTIFY_TOKEN` として注入し、Stop フック
/// からの POST を受信口で照合する。プレーンな [Provider] のため container の
/// 生存期間（＝アプリ起動）中は同一値を返し、再起動で別値になる。旧起動の
/// トークンを持つ POST は照合で弾かれる。
final notifyTokenProvider = Provider<String>((ref) => const Uuid().v4());
