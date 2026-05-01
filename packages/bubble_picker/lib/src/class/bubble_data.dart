part of '../bubble_picker_widget.dart';

/// [BubbleData] is a configuration class that defines the properties of a bubble
/// within the [BubblePicker] widget. It provides options for customizing the
/// appearance and behavior of each bubble.
class BubbleData {
  /// Creates a [BubbleData] object.
  ///
  /// The [radius] must be between 0 and 1 if provided. A [radius] of 1 corresponds to the full height of the widget,
  /// while a [radius] of 0.5 corresponds to half the height of the widget.
  const BubbleData({
    this.color,
    this.radius,
    this.child,
    this.onTapBubble,
    this.imageProvider,
    this.colorFilter,
    this.boxFit,
    this.gradient,
  })  : assert(
          radius == null || (radius > 0 && radius < 1),
          'Radius must be greater than 0 and less than 1 if provided',
        ),
        assert(
          !(color != null && gradient != null),
          'Only one of color or gradient should be provided.',
        );

  /// An optional color to be used as the background of the bubble.
  ///
  /// If an [imageProvider] is also provided, the color will be applied
  /// as an overlay on top of the image.
  final Color? color;

  /// The radius of the bubble, specified as a fraction of the widget's height.
  ///
  /// Must be greater than 0 and less than 1. If not specified, a default value is used.
  final double? radius;

  /// An optional widget to be displayed at the center of the bubble.
  ///
  /// This could be any widget such as an icon, text, or an image.
  final Widget? child;

  /// A callback that is triggered when the bubble is tapped.
  ///
  /// The callback provides the new radius of the bubble after it has been tapped.
  final void Function(double radius)? onTapBubble;

  /// An optional image to be used as the bubble's background.
  ///
  /// If provided, this image is drawn inside the bubble using the specified [boxFit] and [colorFilter].
  final ImageProvider? imageProvider;

  /// An optional color filter to apply to the [imageProvider] if one is provided.
  ///
  /// This can be used to tint the image or apply a blending effect.
  final ColorFilter? colorFilter;

  /// The fit strategy to use when drawing the [imageProvider] inside the bubble.
  ///
  /// Defaults to [BoxFit.cover] if not specified, ensuring the image covers the entire bubble.
  final BoxFit? boxFit;

  /// An optional gradient to be used as the background of the bubble.
  ///
  /// If an [imageProvider] is also provided, the gradient will be applied
  /// as an overlay on top of the image.
  final Gradient? gradient;
}
