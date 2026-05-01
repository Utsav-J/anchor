part of 'bubble_picker_widget.dart';

/// A custom painter that handles rendering of bubbles within the [BubblePicker] widget.
class _BubblePainter extends CustomPainter {
  /// List of bubbles to be painted.
  final List<_Bubble> bubbles;

  /// Creates a [_BubblePainter] instance.
  _BubblePainter(this.bubbles);

  /// Paints the bubbles on the provided canvas.
  ///
  /// This method is called automatically when the widget needs to be repainted.
  /// It iterates over the list of bubbles, drawing each one based on its properties.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(); // Paint object used to draw the bubbles

    // Iterate through each bubble in the list
    for (var bubble in bubbles) {
      // Save the current canvas state
      canvas.save();

      // Create a clipping path in the shape of a circle for the bubble
      Path clipPath = Path()..addOval(Rect.fromCircle(center: Offset(bubble.dx, bubble.dy), radius: bubble.radius));
      canvas.clipPath(clipPath);

      if (bubble.image != null) {
        // If the bubble has an image, draw it as the background
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(center: Offset(bubble.dx, bubble.dy), radius: bubble.radius),
          image: bubble.image!,
          fit: bubble.boxFit ?? BoxFit.cover, // Use BoxFit.cover by default
          colorFilter: bubble.colorFilter, // Apply the color filter if specified
        );
      } else {
        // If no image is provided, draw a solid color background
        paint.color = bubble.color;
        canvas.drawCircle(
          Offset(bubble.dx, bubble.dy),
          bubble.radius,
          paint,
        );
      }

      if (bubble.gradient != null) {
        // If a gradient is specified, apply it as an overlay
        paint.shader = bubble.gradient!.createShader(
          Rect.fromCircle(center: Offset(bubble.dx, bubble.dy), radius: bubble.radius),
        );
        canvas.drawCircle(
          Offset(bubble.dx, bubble.dy),
          bubble.radius,
          paint,
        );
      }

      // Restore the previous canvas state
      canvas.restore();
    }
  }

  /// Determines whether the painter should repaint.
  ///
  /// Returns `true` to indicate that the painter should repaint when the widget is rebuilt.
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
