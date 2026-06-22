/// ───────────────────────────────────────────────
/// セリフ・キャラ設定はすべてここに集約（データ外出し）。
/// トーン：怒らない。「確認する」。妙に丁寧で、事務的な圧。
/// 暴言・人格否定・恫喝はNG。丁寧なのに逆に怖い、を狙う。
/// 音声を足すときは assets/audio/ に下記ファイル名で mp3 を置く。
/// （ファイルが無ければ自動でテキストのみで進行する）
/// ───────────────────────────────────────────────
class CallScript {
  // 発信者（実在しそうで実在しない人物）
  static const String callerName = '進捗確認担当';
  static const String callerOrg = 'プロジェクト推進部';

  // 音声ファイル名（assets/audio/ 配下）
  static const String ringtoneFile = 'ringtone.mp3';
  static const String answerAudioFile = 'answer.mp3';
  static const String voicemailAudioFile = 'voicemail.mp3';

  /// 「出る」を押した直後の第一声
  static String answerLine(String task) =>
      'お疲れ様です。「$task」の件で、進捗確認のお電話をいたしました。'
      '現状、未完了という認識でお間違いないでしょうか。';

  /// 出たあとに選べる返答（ラベル）と、それに対する締めのセリフ
  static const List<Reply> replies = [
    Reply(
      label: 'すみません、まだです…',
      closing: 'はい、承知いたしました。'
          'それでは引き続き、ご対応のほどよろしくお願いいたします。'
          'また改めて、確認のご連絡を差し上げます。',
    ),
    Reply(
      label: 'もう少しで終わります',
      closing: '承知いたしました。'
          '完了のご連絡を、心よりお待ちしております。'
          '何卒よろしくお願いいたします。',
    ),
  ];

  /// 「無視」したときに残る留守電
  static String voicemailLine(String task) =>
      'お世話になっております。進捗確認担当でございます。'
      '「$task」の件につきまして、確認したくご連絡いたしました。'
      'お手すきの際に、折り返しご連絡をお待ちしております。失礼いたします。';
}

class Reply {
  final String label;
  final String closing;
  const Reply({required this.label, required this.closing});
}
