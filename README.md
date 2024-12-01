# 使い方

適当な環境パスに入れておくことを強く推奨します。

```shell
ytdl https://www.youtube.com/watch?v=xxxxxxxxxxx
```

もしくは

```shell
ytdl https://www.youtube.com/watch?v=xxxxxxxxxxx -f
//* --fastでもおけ(linuxだと--fastじゃないとエラーが出る)
```

## 注意点

*--fast*か _-f_ を使った場合はデバイスによっては音声がうまく読み取れないことがあります。
その場合は VLC などのプレイヤーを使って再生してください。

## 免責事項

このプログラムを使用したことによるいかなる損害も作者は責任を負いません。

## ライブラリの感謝など

このプログラムは以下のライブラリの提供に特に感謝します。

- [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart)
- C#でYoutubeExplodeを作成したTyrrrz
- ライブラリをDartに移植したHexer10
- [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart)リポジトリの全ての貢献者

<!-- GitHub のリポジトリの更新をローカルに反映させるには、以下の手順を実行します。

1. **リポジトリのディレクトリに移動**:
   ターミナルまたはコマンドプロンプトを開き、ローカルリポジトリのディレクトリに移動します。

   ```sh
   cd path/to/your/repository
   ```

2. **リモートリポジトリから最新の変更を取得**:
   `git fetch`コマンドを使用して、リモートリポジトリから最新の変更を取得します。

   ```sh
   git fetch origin
   ```

3. **ローカルブランチを更新**:
   `git pull`コマンドを使用して、ローカルブランチをリモートブランチの最新の状態に更新します。

   ```sh
   git pull origin main
   ```

   `main`の部分は、更新したいブランチ名に置き換えてください。

これで、GitHub のリポジトリの更新がローカルに反映されます。 -->
