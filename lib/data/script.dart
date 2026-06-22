import 'dart:math';

/// 着信キャラクターと台詞を集約したデータ。
/// 音声ファイルが未配置の場合も、画面上のテキストだけで進行する。
class CallScript {
  static const String ringtoneFile = 'ringtone.mp3';
  static final Random _random = Random();

  static const List<CallCharacter> characters = [
    CallCharacter(
      id: 'committee',
      name: '進捗管理推進委員会',
      org: 'タスク管理部 進捗確認課',
      answerTemplate: 'お疲れ様です。あのー今回お電話差し上げたのはですね、'
          '登録タスク「{task}」の進捗確認の件でお伺いしたいことがありまして、'
          'こちら、現在の登録状況としては未完了となっているのですが、'
          'お間違いないでしょうか？',
      voicemailTemplate: 'お世話になっております。進捗管理推進委員会でございます。'
          'あのー登録タスク「{task}」の件なんですけれども、'
          '現状未完了という状況になっておりまして、ご確認いただけますでしょうか。'
          '折り返しのご連絡、お待ちしております。失礼いたします。',
      answerAudioFile: 'committee_answer.mp3',
      voicemailAudioFile: 'committee_voicemail.mp3',
      replies: [
        Reply(
          label: 'すみません、まだです…',
          closing: '承知いたしました。では改めてご確認のご連絡を差し上げます。',
          audioFile: 'committee_still.mp3',
        ),
        Reply(
          label: 'もう少しで終わります',
          closing: 'さようでございますか。完了次第ご一報いただけますと幸いです。',
          audioFile: 'committee_soon.mp3',
        ),
      ],
    ),
    CallCharacter(
      id: 'entity',
      name: '進捗管理生命体���',
      org: '��������',
      answerTemplate: '（何を言っているかわからないが、どうやら登録タスク「{task}」の'
          '期限切れについてモノ申しているようだ）',
      voicemailTemplate: '（登録タスク「{task}」について、未知の言語でまくしたてている）',
      answerAudioFile: 'entity_answer.mp3',
      voicemailAudioFile: 'entity_voicemail.mp3',
      replies: [
        Reply(
          label: 'ま、まだです',
          closing: '（未知の言語で急かしているようだ）',
          audioFile: 'entity_still.mp3',
        ),
        Reply(
          label: 'もうすぐです',
          closing: '（チカチカ光りながら待機しているようだ）',
          audioFile: 'entity_soon.mp3',
        ),
      ],
    ),
    CallCharacter(
      id: 'mother',
      name: 'おかあちゃん',
      org: '',
      answerTemplate: 'もしもし？ あのね、登録タスク「{task}」、まだ終わってないの？'
          '大丈夫？ 無理してない？ 早めにやっといたほうがいいと思うんだけどなあ…',
      voicemailTemplate: 'もしもし、おかあちゃんだけど。登録タスク「{task}」、'
          'どうなったかなと思って。終わったら連絡ちょうだいね。'
          'ごはんちゃんと食べるのよ。',
      answerAudioFile: 'mother_answer.mp3',
      voicemailAudioFile: 'mother_voicemail.mp3',
      replies: [
        Reply(
          label: 'まだなんだ…',
          closing: 'そっかあ、無理しないでね。でも早めにやっといたほうがいいよ。'
              '無理はしないでね。',
          audioFile: 'mother_still.mp3',
        ),
        Reply(
          label: 'もうすぐ！',
          closing: 'ほんと？ よかった～。終わったら教えてね。',
          audioFile: 'mother_soon.mp3',
        ),
      ],
    ),
  ];

  static CallCharacter randomCharacter() =>
      characters[_random.nextInt(characters.length)];

  static CallCharacter characterById(String id) => characters.firstWhere(
        (character) => character.id == id,
        orElse: () => characters.first,
      );
}

class CallCharacter {
  final String id;
  final String name;
  final String org;
  final String answerTemplate;
  final String voicemailTemplate;
  final String answerAudioFile;
  final String voicemailAudioFile;
  final List<Reply> replies;

  const CallCharacter({
    required this.id,
    required this.name,
    required this.org,
    required this.answerTemplate,
    required this.voicemailTemplate,
    required this.answerAudioFile,
    required this.voicemailAudioFile,
    required this.replies,
  });

  String answerLine(String task) => answerTemplate.replaceAll('{task}', task);

  String voicemailLine(String task) =>
      voicemailTemplate.replaceAll('{task}', task);
}

class Reply {
  final String label;
  final String closing;
  final String audioFile;

  const Reply({
    required this.label,
    required this.closing,
    required this.audioFile,
  });
}
