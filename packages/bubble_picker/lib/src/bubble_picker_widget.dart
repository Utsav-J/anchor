import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

part 'bubble_painter.dart';
part 'class/bubble.dart';
part 'class/bubble_data.dart';
part 'util/kalman_filter.dart';

/// A custom widget that displays a collection of interactive bubbles.
/// The bubbles are attracted towards a central point and repelled from each other.
/// Users can interact with the bubbles by tapping or dragging them around.
class BubblePicker extends StatefulWidget {
  /// The size of the widget. This determines the area where the bubbles will be displayed.
  final Size size;

  /// A list of [BubbleData] objects that define the appearance and behavior of each bubble.
  final List<BubbleData> bubbles;

  /// Creates a [BubblePicker] widget.
  const BubblePicker({
    Key? key,
    this.size = const Size(400, 800), // Default size if not specified
    required this.bubbles,
  }) : super(key: key);

  @override
  State<BubblePicker> createState() => _BubblePickerState();
}

class _BubblePickerState extends State<BubblePicker> with SingleTickerProviderStateMixin {
  List<_Bubble> bubbles = [];
  late AnimationController _controller; // Controls the animation of the bubbles
  Offset clusterCenter = const Offset(200, 400); // Initial center of the bubble cluster
  Offset velocity = Offset.zero; // Velocity of the cluster center
  Stopwatch? _settleWatch;

  final double friction = 0.95; // Velocity damping factor
  final double attractionStrength = 0.009; // Strength of attraction towards the cluster center
  final double repulsionStrength = 0.5; // Strength of repulsion between bubbles

  @override
  void initState() {
    super.initState();

    // Initialize the bubbles and start the animation
    _initializeBubbles();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Duration of one animation cycle
      vsync: this,
    )..addListener(() {
        if (bubbles.isEmpty) return;

        setState(() {
          // Update the position of the cluster center
          velocity = Offset(velocity.dx * friction, velocity.dy * friction);
          clusterCenter += velocity;

          final elapsedMs = _settleWatch?.elapsedMilliseconds ?? 0;
          const settleMs = 2600.0;
          final t = (elapsedMs / settleMs).clamp(0.0, 1.0);
          final easeOut = Curves.easeOutCubic.transform(t);
          // Strong pull-in at first; calm to baseline so the layout can go stationary.
          final attraction =
              attractionStrength * (1.0 + 3.8 * (1.0 - easeOut));
          final velocityDamping = 0.935 + (0.985 - 0.935) * easeOut;

          for (var bubble in bubbles) {
            bubble.update(
              bubbles,
              clusterCenter,
              widget.size,
              attraction,
              repulsionStrength,
              velocityDamping: velocityDamping,
            );
          }

          if (elapsedMs >= 2600) {
            for (final b in bubbles) {
              if (b.velocity.distanceSquared < 0.06) {
                b.velocity = Offset.zero;
              }
            }
          }
        });
      });
    _controller.repeat(); // Repeat the animation indefinitely
  }

  /// Initializes the list of bubbles with their respective images and properties.
  Future<void> _initializeBubbles() async {
    bubbles = [];
    for (var bubbleData in widget.bubbles) {
      final image = await loadImage(bubbleData.imageProvider); // Load the image for the bubble

      bubbles.add(
        _Bubble.fromData(
          Offset(clusterCenter.dx, clusterCenter.dy),
          data: bubbleData,
          image: image,
        ),
      );
    }
    _settleWatch = Stopwatch()..start();
    setState(() {}); // Update the UI with the initialized bubbles
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller when the widget is removed from the tree
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Update the cluster center position based on the user's drag
            clusterCenter += details.delta;
            for (var bubble in bubbles) {
              // Move each bubble accordingly
              bubble.dx += details.delta.dx;
              bubble.dy += details.delta.dy;
            }
          });
        },
        onTapUp: (details) {
          setState(() {
            final tapPosition = details.localPosition;
            for (var bubble in bubbles) {
              // Check if the tap was within a bubble
              if ((Offset(bubble.dx, bubble.dy) - tapPosition).distance <= bubble.radius) {
                // Size changes are handled by the app (selection), not cumulative taps.
                bubble.onTapBubble?.call(bubble.radius);
                break;
              }
            }
          });
        },
        child: Stack(
          children: [
            // CustomPaint widget to draw the bubbles
            CustomPaint(
              size: widget.size,
              painter: _BubblePainter(bubbles), // Custom painter for rendering the bubbles
            ),
            // Render each bubble's child widget
            ...bubbles.map((bubble) {
              return Positioned(
                left: bubble.dx - bubble.radius,
                top: bubble.dy - bubble.radius,
                child: SizedBox(
                  width: bubble.radius * 2,
                  height: bubble.radius * 2,
                  child: Center(
                    child: bubble.child, // Render the child widget within the bubble
                  ),
                ),
              );
            }).toList(),
          ],
        ));
  }
}

/// Extension method on [Offset] to normalize the offset vector.
extension NormalizeOffset on Offset {
  Offset normalize() {
    double length = distance;
    if (length == 0) return this;
    return this / length; // Normalize by dividing by the vector's length
  }
}

/// Asynchronously loads an image from an [ImageProvider].
/// Returns a [ui.Image] that can be used for drawing, or null if no image provider is given.
Future<ui.Image?> loadImage(ImageProvider? provider) async {
  if (provider == null) return null;
  final completer = Completer<ui.Image>();
  final imageStream = provider.resolve(ImageConfiguration.empty);
  final listener = ImageStreamListener(
    (ImageInfo info, bool synchronousCall) {
      completer.complete(info.image); // Completes with the loaded image
    },
    onError: (exception, stackTrace) {
      throw exception; // Propagate errors
    },
  );
  imageStream.addListener(listener); // Start loading the image
  return completer.future; // Return a future that completes when the image is loaded
}
