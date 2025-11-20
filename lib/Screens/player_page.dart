// lib/Screens/player_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerPage extends StatefulWidget {
  final String title;
  final int durationSeconds;
  final String albumAsset;
  final int index;
  final int total;
  final Color accent;

  const PlayerPage({
    super.key,
    required this.title,
    required this.durationSeconds,
    required this.albumAsset,
    required this.index,
    required this.total,
    required this.accent,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool isPlaying = true;
  double progress = 0.0;
  Timer? _timer;
  double verticalDrag = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _startProgressTimer();
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  void _startProgressTimer() {
    _timer?.cancel();
    final total = widget.durationSeconds;
    const tick = Duration(milliseconds: 500);
    _timer = Timer.periodic(tick, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        progress += tick.inMilliseconds / 1000 / total;
        if (progress >= 1.0) {
          progress = 1.0;
          isPlaying = false;
          _rotationController.stop();
          t.cancel();
        }
      });
    });
  }

  void _togglePlay() {
    HapticFeedback.lightImpact();
    setState(() => isPlaying = !isPlaying);
    if (isPlaying) {
      if (!_rotationController.isAnimating) _rotationController.repeat();
      _startProgressTimer();
    } else {
      // gentle stop
      final cur = _rotationController.value;
      final target = (cur + 0.01).clamp(0.0, 1.0);
      _rotationController
          .animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) {
            try {
              _rotationController.stop();
            } catch (_) {}
          });
      _timer?.cancel();
    }
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> _openLyrics() async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (ctx, sc) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: sc,
              children: [
                Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < 20; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "Lyrics line ${i + 1} — sample lyric...",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final duration = widget.durationSeconds;
    final elapsed = (progress * duration).round();
    final remaining = (duration - elapsed).clamp(0, duration);

    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    // pick artwork size responsively: don't exceed a fraction of screen height
    double artworkSize = screenW * 0.56; // base by width
    final maxByHeight =
        screenH * 0.44; // limit by height to avoid bottom overflow
    if (artworkSize > maxByHeight) artworkSize = maxByHeight;

    return GestureDetector(
      onVerticalDragUpdate: (d) => setState(() => verticalDrag += d.delta.dy),
      onVerticalDragEnd: (d) {
        if (verticalDrag > 140) {
          Navigator.pop(context);
        } else {
          setState(() => verticalDrag = 0.0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(
          0,
          verticalDrag.clamp(0.0, 400.0),
          0,
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // blurred background artwork
              Positioned.fill(
                child: Image.asset(widget.albumAsset, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.56)),
              ),
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // top row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_downward),
                            color: Colors.white,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context);
                            },
                          ),
                          const Spacer(),
                          Text(
                            '${widget.index + 1}/${widget.total}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            color: Colors.white70,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // main area - use Flexible so controls can fit on short screens
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // vinyl artwork - clipped to circle and constrained
                            RotationTransition(
                              turns: _rotationController,
                              child: ClipOval(
                                child: Image.asset(
                                  widget.albumAsset,
                                  width: artworkSize,
                                  height: artworkSize,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Bad Omens',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // bottom controls in safe area
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                _fmt(elapsed),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                    ),
                                  ),
                                  child: Slider(
                                    value: progress.clamp(0.0, 1.0),
                                    activeColor: accent,
                                    inactiveColor: Colors.white12,
                                    onChanged: (v) =>
                                        setState(() => progress = v),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _fmt(remaining),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 28,
                                color: Colors.white70,
                                onPressed: () {},
                                icon: const Icon(Icons.skip_previous),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(0.28),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                                child: FloatingActionButton(
                                  backgroundColor: Colors.white,
                                  onPressed: _togglePlay,
                                  child: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: accent,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                iconSize: 28,
                                color: Colors.white70,
                                onPressed: () {},
                                icon: const Icon(Icons.skip_next),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: _openLyrics,
                                icon: Icon(Icons.lyrics, color: Colors.white70),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.queue_music,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
