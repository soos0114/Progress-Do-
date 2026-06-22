# 鬼詰めToDo — セットアップ手順

この `lib/` `pubspec.yaml` `assets/` は、**空の Flutter プロジェクトに乗せて動かす**前提のソース一式です。
（着信画面を主役に、TODO側は最小構成）

---

## 1. プロジェクトを用意して乗せる

```bash
flutter create kizume_todo        # 既存プロジェクトでもOK
cd kizume_todo
```

このzipの中身で上書き：
- `pubspec.yaml` を置き換え
- `lib/` をまるごと置き換え
- `assets/` をコピー

```bash
flutter pub get
```

---

## 2. Android 側の設定（3か所）

### 2-1. 権限とレシーバ — `android/app/src/main/AndroidManifest.xml`

`<manifest>` 直下に権限を追加：

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<!-- ① 昇格（アプリ外で勝手にフルスクリーン着信）にする場合のみ -->
<!-- <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/> -->
```

`<application>` の中（`<activity>` と並べて）に、flutter_local_notifications のレシーバを追加：

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### 2-2. desugaring を有効化 — `android/app/build.gradle`

flutter_local_notifications はこれが無いとビルドが落ちます。

```gradle
android {
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    defaultConfig {
        minSdkVersion 21   // 21以上
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
```

（Kotlin DSL `build.gradle.kts` の場合は各設定をKTS記法に読み替え）

---

## 3. 実行

```bash
flutter run
```

初回起動で通知の許可を聞かれます（許可してください）。
「正確なアラーム」を端末がブロックしている場合は、設定→アプリ→鬼詰めToDo→アラームとリマインダー を許可。

---

## 4. 触り方

- タスク追加で期限を「1分後」などにして待つと、アプリのホーム画面を表示中なら自動で着信画面へ切り替わります。
- アプリがバックグラウンド、または端末がロック中の場合は、フルスクリーン通知の権限が許可されていれば着信画面が表示されます。端末の設定によっては通知のタップが必要です。
- 着信画面：着信中は端末の「戻る」で逃げられません（出る／無視を必ず選ぶ＝ネタ）。
  - **出る** → 進捗確認のセリフ → 返答を選ぶ → 締め → 終了
  - **無視** → 留守電が1件残る（右上のボイスメールに溜まる）

---

## 5. 音声（ElevenLabs）

`assets/audio/` に下記を置くと鳴ります（無くてもテキストで進行）：

| ファイル | 用途 |
|---|---|
| `ringtone.mp3` | 着信音（ループ） |
| `answer.mp3` | 「出る」直後の第一声 |
| `voicemail.mp3` | 留守電／締め |

読み上げる文面は `lib/data/script.dart`。トーンは「妙に丁寧・事務的な圧」。
ファイルを足したら `flutter pub get`（assetsディレクトリ自体は既に宣言済みなので不要なことが多い）→ 再ビルド。

---

## 6. よく変える場所

- **セリフ・キャラ名・音声ファイル名**：`lib/data/script.dart`
- **保存の中身を差し替え**：`lib/services/storage.dart`（`Store` を実装すれば差し替え可）
- **着信の出し方（②→①昇格）**：`lib/services/notifications.dart` の
  `fullScreenIntent` を true ＋ マニフェストに `USE_FULL_SCREEN_INTENT`
- **着信画面の見た目・通話フロー**：`lib/screens/incoming_call_screen.dart`

---

## 7. 既知の注意

- 音声の `mp3` を置くまではミュート進行（仕様）。
- 通知の「正確な時刻」発火は端末の省電力設定の影響を受けることがあります。
- Android 14以降では、フルスクリーン通知が端末側で許可されているか確認してください。
- iOSは未対応（Android限定方針）。
