import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../shared/themes/theme_provider.dart';

class VideoNodeWidget extends StatefulWidget {
  final String src;
  final BloomTheme t;
  const VideoNodeWidget({super.key, required this.src, required this.t});

  @override
  State<VideoNodeWidget> createState() => _VideoNodeWidgetState();
}

class _VideoNodeWidgetState extends State<VideoNodeWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.src))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        decoration: BoxDecoration(
          color: widget.t.bgSurface2,
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: CircularProgressIndicator(color: widget.t.primary),
          ),
        ),
      );
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          Semantics(
            button: true,
            label: _playing ? 'Jeda video' : 'Putar video',
            child: GestureDetector(
              onTap: () {
                ProviderScope.containerOf(context).read(soundProvider).playClick();
                setState(() => _playing = !_playing);
                _playing ? _controller!.play() : _controller!.pause();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
      VideoProgressIndicator(
        _controller!,
        allowScrubbing: true,
        padding: const EdgeInsets.all(8),
        colors: VideoProgressColors(
          playedColor: widget.t.primary,
          bufferedColor: widget.t.primary.withValues(alpha: 0.3),
          backgroundColor: widget.t.bgSurface2,
        ),
      ),
    ]);
  }
}
