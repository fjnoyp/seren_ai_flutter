import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'dart:async';

import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_service.dart';

final animationTickProvider = StreamProvider<void>((ref) async* {
  while (true) {
    await Future.delayed(const Duration(milliseconds: 16)); // ~60 FPS
    yield null;
  }
});

// This widget isn't being used yet because it's broken
// It supposed to represent the IA voice as a wave
class ListenVolumeWidget extends ConsumerWidget {
  const ListenVolumeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(textToSpeechServiceProvider);
    final isPlaying =
        ttsState == TextToSpeechStateEnum.speaking;

    if (isPlaying) {
      ref.watch(animationTickProvider);
    }

    return CustomPaint(
      size: const Size(double.infinity, 30),
      painter: WaveLinePainter(
        amplitude: isPlaying ? 10.0 : 0.0,
        color: Theme.of(context).colorScheme.outlineVariant,
        isPlaying: isPlaying,
      ),
    );
  }
}

class WaveLinePainter extends CustomPainter {
  final double amplitude;
  final Color color;
  final bool isPlaying;
  static double timeOffset = 0;

  WaveLinePainter({
    required this.amplitude,
    required this.color,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final mid = height / 2;

    if (isPlaying) {
      timeOffset = DateTime.now().millisecondsSinceEpoch / 50;
    }

    path.moveTo(0, mid);

    // Draw the wave from left to center
    for (double i = 0; i <= width / 2; i++) {
      final y = mid + sin((i / 30) + timeOffset) * amplitude;
      path.lineTo(i, y);
    }

    // Mirror the wave from center to right
    for (double i = width / 2; i < width; i++) {
      final mirrorX = width - i;
      final y = mid + sin((mirrorX / 30) + timeOffset) * amplitude;
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveLinePainter oldDelegate) {
    // Always repaint when amplitude > 0 to keep animation going
    return amplitude > 0;
  }
}
