ここに ElevenLabs で生成した mp3 を置くと、着信・通話・留守電で音声が鳴ります。
ファイルが無くてもアプリは動きます（その場合はテキスト字幕のみで進行）。

使うファイル名（lib/data/script.dart で変更可）:
  ringtone.mp3   … 着信音（ループ再生）
  answer.mp3     … 「出る」直後の第一声
  voicemail.mp3  … 留守電／締めのセリフ

セリフ本文は lib/data/script.dart にあります。音声を作るときはそこの文面を読み上げさせてください。
