// lib/Widgets/mini_player.dart
import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  final String title;
  final String artist;
  final String albumAsset;
  final double progress;
  final bool isPlaying;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;

  const MiniPlayer({
    super.key,
    required this.title,
    required this.artist,
    required this.albumAsset,
    required this.progress,
    required this.isPlaying,
    required this.accent,
    required this.onTap,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            // album artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                albumAsset,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  width: 44,
                  height: 44,
                  color: Colors.white12,
                  child: const Icon(Icons.music_note, color: Colors.white24),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // title + artist + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // thin progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // play/pause button
            IconButton(
              onPressed: onPlayPause,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: accent,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
