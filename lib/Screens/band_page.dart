// lib/Screens/band_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../Widgets/song_tile.dart';
import '../Widgets/mini_player.dart';
import 'player_page.dart';

class Song {
  final String title;
  final int seconds;
  Song(this.title, this.seconds);
}

class BandPage extends StatefulWidget {
  const BandPage({super.key});
  static const String albumAsset = 'assets/images/bad_omens_album.jpeg';

  @override
  State<BandPage> createState() => _BandPageState();
}

class _BandPageState extends State<BandPage> with TickerProviderStateMixin {
  final Color accent = const Color(0xFFB32424);
  late final AnimationController _albumPulse;
  int? playingIndex;
  bool isPlaying = false;
  double progress = 0.0;
  Timer? _timer;

  final List<Song> songs = [
    Song("CONCRETE JUNGLE", 200),
    Song("Nowhere to Go", 246),
    Song("Take Me First", 199),
    Song("THE DEATH OF PEACE OF MIND", 241),
    Song("What It Cost", 103),
    Song("Like a Villain", 221),
    Song("bad decisions", 184),
    Song("Just Pretend", 255),
    Song("The Grey", 212),
    Song("Who Are You?", 198),
    Song("Somebody else.", 180),
    Song("IDWT\$", 170),
    Song("What Do You Want from Me?", 226),
    Song("ARTIFICIAL SUICIDE", 230),
    Song("Miracle", 200),
  ];

  @override
  void initState() {
    super.initState();
    _albumPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _albumPulse.dispose();
    super.dispose();
  }

  void _startPlaying(int index) {
    _timer?.cancel();
    setState(() {
      playingIndex = index;
      isPlaying = true;
      progress = 0.0;
    });
    final total = songs[index].seconds;
    const tick = Duration(milliseconds: 500);
    _timer = Timer.periodic(tick, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        progress += tick.inMilliseconds / 1000 / total;
        if (progress >= 1.0) {
          progress = 0.0;
          isPlaying = false;
          playingIndex = null;
          t.cancel();
        }
      });
    });
  }

  String _fmt(int s) =>
      "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final cardBg = Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(BandPage.albumAsset, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Text(
                    "Bad Omens",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Hero(
                              tag: "albumHero",
                              child: ScaleTransition(
                                scale: Tween(
                                  begin: 0.97,
                                  end: 1.02,
                                ).animate(_albumPulse),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    BandPage.albumAsset,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              "THE DEATH OF PEACE OF MIND",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 12),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              onPressed: () {
                                _startPlaying(0);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerPage(
                                      title: songs[0].title,
                                      durationSeconds: songs[0].seconds,
                                      albumAsset: BandPage.albumAsset,
                                      index: 0,
                                      total: songs.length,
                                      accent: accent,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("Play Preview"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Tracklist",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final s = songs[index];
                      final active = index == playingIndex && isPlaying;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SongTile(
                          title: s.title,
                          duration: _fmt(s.seconds),
                          isPlaying: active,
                          progress: active ? progress : 0.0,
                          accentColor: accent,
                          textColor: Colors.white,
                          background: cardBg,
                          indexNumber: index + 1,
                          onTap: () {
                            _startPlaying(index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerPage(
                                  title: s.title,
                                  durationSeconds: s.seconds,
                                  albumAsset: BandPage.albumAsset,
                                  index: index,
                                  total: songs.length,
                                  accent: accent,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          if (playingIndex != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: MiniPlayer(
                title: songs[playingIndex!].title,
                artist: "Bad Omens",
                albumAsset: BandPage.albumAsset,
                progress: progress,
                isPlaying: isPlaying,
                accent: accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerPage(
                        title: songs[playingIndex!].title,
                        durationSeconds: songs[playingIndex!].seconds,
                        albumAsset: BandPage.albumAsset,
                        index: playingIndex!,
                        total: songs.length,
                        accent: accent,
                      ),
                    ),
                  );
                },
                onPlayPause: () {
                  setState(() => isPlaying = !isPlaying);
                },
              ),
            ),
        ],
      ),
    );
  }
}
