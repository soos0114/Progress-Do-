ここに ElevenLabs で生成した mp3 を置くと、着信・通話・留守電で音声が鳴ります。
ファイルが無くてもアプリは動きます（その場合はテキスト字幕のみで進行）。

使うファイル名（lib/data/script.dart で変更可）:
  ringtone.mp3              … 着信音（ループ再生）

  committee_answer.mp3      … 委員会の第一声
  committee_still.mp3       … 委員会「まだです」への返答
  committee_soon.mp3        … 委員会「もう少し」への返答
  committee_voicemail.mp3   … 委員会の留守電

  entity_answer.mp3         … 生命体の第一声
  entity_still.mp3          … 生命体「まだです」への返答
  entity_soon.mp3           … 生命体「もうすぐ」への返答
  entity_voicemail.mp3      … 生命体の留守電

  mother_answer.mp3         … おかあちゃんの第一声
  mother_still.mp3          … おかあちゃん「まだ」への返答
  mother_soon.mp3           … おかあちゃん「もうすぐ」への返答
  mother_voicemail.mp3      … おかあちゃんの留守電

セリフ本文は lib/data/script.dart にあります。音声を作るときはそこの文面を読み上げさせてください。
