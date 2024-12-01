// import 'package:youtube_explode_dart/youtube_explode_dart.dart' ;

// void main(List<String> arguments)async {
// var yt = YoutubeExplode();
// var video = await yt.videos.get('https://www.youtube.com/watch?v=cjgfH-v4rRA'); // Returns a Video instance.

// print('Title: ${video.title}');
// }

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';

Future<void> main(List<String> args) async {
  final yt = YoutubeExplode();
  if (args == null || args.isEmpty) {
    print('URLを指定してください');
    return;
  }
  final url = Uri.parse(args[0]);
  final videoId = url.queryParameters['v'];
  print(videoId);
  if (videoId == null) {
    print('URLが不正です');
    return;
  }
  final v = await yt.videos.get(videoId);
  final manifest =
      await yt.videos.streams.getManifest(videoId, ytClients: [
    YoutubeApiClient.android,
  ]);

  final audio = manifest.audioOnly;
  final video = manifest.videoOnly;
  // print(audio.withHighestBitrate());

  final audioStreamInfo = audio.withHighestBitrate();
  final audioStream = yt.videos.streams.get(audioStreamInfo);

  // ファイル名を安全な形式に変換
  final safeTitle = v.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final audioFile = File("$safeTitle.temp.${audioStreamInfo.container.name}");
  await audioStream.pipe(audioFile.openWrite());

  final videoStreamInfo = video.withHighestBitrate();
  final videoStream = yt.videos.streams.get(videoStreamInfo);
  final videoFile = File('$safeTitle.temp.${videoStreamInfo.container.name}');
  await videoStream.pipe(videoFile.openWrite());

  yt.close();

  // ffmpegで音声と動画を結合
  final result = await Process.run('ffmpeg', [
    '-i',
    audioFile.path,
    '-i',
    videoFile.path,
    '-c:a',
    'aac',
    '$safeTitle.mp4',
  ]);

  if (result.exitCode == 0) {
    print('ファイルの結合に成功しました: $safeTitle.mp4');
  } else {
    print('ファイルの結合に失敗しました: ${result.stderr}');
  }

  // 結合したファイルを削除
  await audioFile.delete();
  await videoFile.delete();
}

// はい、コメントの通りです。
//`await stream.pipe(file.openWrite());` は、
//`stream` のデータを `file` に書き込むためのコードです。
//`pipe` メソッドを使うことで、ストリームのデータを逐次的に書き込むことができます。

