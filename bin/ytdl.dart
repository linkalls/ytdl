// import 'package:youtube_explode_dart/youtube_explode_dart.dart' ;

// void main(List<String> arguments)async {
// var yt = YoutubeExplode();
// var video = await yt.videos.get('https://www.youtube.com/watch?v=cjgfH-v4rRA'); // Returns a Video instance.

// print('Title: ${video.title}');
// }
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'package:console_bars/console_bars.dart';

Future<void> main(List<String> args) async {
  final yt = YoutubeExplode();
  if (args.isEmpty) {
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

  final audioStreamInfo = audio.withHighestBitrate();
  final audioStream = yt.videos.streams.get(audioStreamInfo);

  final safeTitle = v.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final audioFile = File("$safeTitle.audio.${audioStreamInfo.container.name}");
  final audioSink = audioFile.openWrite();

  final audioProgress = FillingBar(
    desc: "音声ダウンロード中",
    total: audioStreamInfo.size.totalBytes,
    percentage: true,
  );

  int audioDownloaded = 0;
  await for (final data in audioStream) {
    audioSink.add(data);
    audioDownloaded += data.length;
    audioProgress.update(audioDownloaded);
  }
  await audioSink.close();

  final videoStreamInfo = video.withHighestBitrate();
  final videoStream = yt.videos.streams.get(videoStreamInfo);
  final videoFile = File('$safeTitle.video.${videoStreamInfo.container.name}');
  final videoSink = videoFile.openWrite();

  final videoProgress = FillingBar(
    desc: "動画ダウンロード中",
    total: videoStreamInfo.size.totalBytes,
    percentage: true,
  );

  int videoDownloaded = 0;
  await for (final data in videoStream) {
    videoSink.add(data);
    videoDownloaded += data.length;
    videoProgress.update(videoDownloaded);
  }
  await videoSink.close();

  yt.close();

  print('\n音声ファイルのパス: ${audioFile.path}');
  print('動画ファイルのパス: ${videoFile.path}');

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

  if (await audioFile.exists()) {
    await audioFile.delete();
  } else {
    print('音声ファイルが見つかりませんでした: ${audioFile.path}');
  }

  if (await videoFile.exists()) {
    await videoFile.delete();
  } else {
    print('動画ファイルが見つかりませんでした: ${videoFile.path}');
  }
}

// はい、コメントの通りです。
//`await stream.pipe(file.openWrite());` は、
//`stream` のデータを `file` に書き込むためのコードです。
//`pipe` メソッドを使うことで、ストリームのデータを逐次的に書き込むことができます。

