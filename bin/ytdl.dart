// import 'package:youtube_explode_dart/youtube_explode_dart.dart' ;

// void main(List<String> arguments)async {
// var yt = YoutubeExplode();
// var video = await yt.videos.get('https://www.youtube.com/watch?v=cjgfH-v4rRA'); // Returns a Video instance.

// print('Title: ${video.title}');
// }
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'package:console_bars/console_bars.dart';
import "package:args/args.dart";

Future<void> main(List<String> args) async {
  final parser = ArgParser();
  parser.addFlag("fast", abbr: "f", help: "高速モードでダウンロードします");
  final result = parser.parse(args);
  if (result["fast"]) {
    print("高速モードでダウンロードします");
  }
  final yt = YoutubeExplode();
  if (args.isEmpty) {
    print('URLを指定してください');
    return;
  }
  final url = Uri.parse(args[0]);
  final videoId = url.queryParameters['v'];
  if (videoId == null) {
    print('URLが不正です');
    return;
  }
  final v = await yt.videos.get(videoId);
  final manifest = await yt.videos.streams.getManifest(videoId, ytClients: [
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
  print("これから動画と音声の結合を行います");

  var exitCode;

  // ffmpegがインストールされているか確認
  try {
    final ffmpegCheck = await Process.run('ffmpeg', ['-version']);
    if (ffmpegCheck.exitCode != 0) {
      print('ffmpegがインストールされていません。インストールしてください。');
      return;
    }
  } catch (e) {
    print('ffmpegがインストールされていません。インストールしてください。');
    return;
  }

  if (result["fast"]) {
    final process = await Process.run('ffmpeg', [
      '-i',
      videoFile.path,
      '-i',
      audioFile.path,
      '-shortest',
      '-c',
      'copy',
      '$safeTitle.mp4',
    ]);
    exitCode = process.exitCode;
  } else {
    final process = await Process.run('ffmpeg', [
      '-i',
      videoFile.path,
      '-i',
      audioFile.path,
      '-c:v',
      'libx264',
      '-c:a',
      'aac',
      '-strict',
      'experimental',
      '-b:a',
      '192k',
      '-movflags',
      '+faststart',
      '-preset',
      'fast',
      '$safeTitle.mp4',
    ]);
    exitCode = process.exitCode;
  }

  // final process = await Process.run('ffmpeg', [
  //   '-i',
  //   videoFile.path,
  //   '-i',
  //   audioFile.path,
  //   '-shortest',
  //   '-c',
  //   'copy',
  //   '$safeTitle.mp4',
  // ]);

//* process.startのときは、標準出力をリッスンすることができる
// print(process.stdout);
  // process.stdout.transform(utf8.decoder).listen((data) {
  //   print(data);
  // });

  // process.stderr.transform(utf8.decoder).listen((data) {
  //   print(data);
  // });

  if (exitCode == 0) {
    print('ファイルの結合に成功しました: $safeTitle.mp4');
  } else {
    print('ファイルの結合に失敗しました');
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

