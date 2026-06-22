String two(int n) => n.toString().padLeft(2, '0');

String fmtDateTime(DateTime d) =>
    '${d.year}/${two(d.month)}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';

/// 期限までの相対表示。超過していれば「◯分超過」。
String fmtRelative(DateTime due) {
  final diff = due.difference(DateTime.now());
  if (diff.isNegative) {
    final d = -diff;
    if (d.inDays > 0) return '${d.inDays}日 超過';
    if (d.inHours > 0) return '${d.inHours}時間 超過';
    if (d.inMinutes > 0) return '${d.inMinutes}分 超過';
    return 'たった今 超過';
  } else {
    if (diff.inDays > 0) return 'あと${diff.inDays}日';
    if (diff.inHours > 0) return 'あと${diff.inHours}時間';
    if (diff.inMinutes > 0) return 'あと${diff.inMinutes}分';
    return 'まもなく';
  }
}
