import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const ClopcatApp());
}

class ClopcatApp extends StatelessWidget {
  const ClopcatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clopcat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5C82)),
        useMaterial3: true,
      ),
      home: const EditorPage(),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final TextEditingController _urlController;
  VideoPlayerController? _controller;
  bool _isLoading = false;
  bool _isPlaying = false;
  String _status = 'Paste a public video URL to begin.';

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
    );
  }

  Future<void> _loadVideo(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _status = 'Please provide a valid URL.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Loading video...';
    });

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await controller.initialize();
      if (!mounted) return;

      await controller.setLooping(true);
      setState(() {
        _controller?.dispose();
        _controller = controller;
        _status = 'Preview ready.';
        _isLoading = false;
      });
    } catch (error) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _status = 'Unable to load the video: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (_isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    setState(() {
      _isPlaying = controller.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clopcat'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Open a public video URL',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'https://example.com/video.mp4',
                          labelText: 'Video URL',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: _isLoading ? null : () => _loadVideo(_urlController.text),
                            icon: const Icon(Icons.ondemand_video),
                            label: const Text('Load video'),
                          ),
                          const SizedBox(width: 12),
                          if (_controller != null && _controller!.value.isInitialized)
                            FilledButton.tonalIcon(
                              onPressed: _togglePlay,
                              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                              label: Text(_isPlaying ? 'Pause' : 'Play'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _controller != null && _controller!.value.isInitialized
                                ? AspectRatio(
                                    aspectRatio: _controller!.value.aspectRatio,
                                    child: VideoPlayer(_controller!),
                                  )
                                : Center(
                                    child: Text(
                                      _status,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_controller != null && _controller!.value.isInitialized)
                          ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: _controller!,
                            builder: (context, value, _) {
                              final progress = value.position.inSeconds;
                              final duration = value.duration.inSeconds;
                              return Column(
                                children: [
                                  LinearProgressIndicator(
                                    value: duration > 0 ? progress / duration : 0,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
