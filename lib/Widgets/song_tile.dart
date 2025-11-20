import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final String title;
  final String duration;
  final double progress;
  final bool isPlaying;
  final Color accentColor;
  final Color textColor;
  final Color background;
  final VoidCallback onTap;
  final int indexNumber;

  const SongTile({
    super.key,
    required this.title,
    required this.duration,
    required this.progress,
    required this.isPlaying,
    required this.onTap,
    required this.accentColor,
    required this.textColor,
    required this.background,
    required this.indexNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying ? accentColor.withOpacity(0.3) : Colors.white12,
            width: isPlaying ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  indexNumber.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              duration,
              style: TextStyle(color: textColor.withOpacity(0.75)),
            ),
          ],
        ),
      ),
    );
  }
}
