import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';

/// Cached network image widget with placeholder and error handling
class NetworkImageWidget extends StatelessWidget {
  /// Image URL to load
  final String? imageUrl;

  /// Widget width
  final double? width;

  /// Widget height
  final double? height;

  /// How to fit the image
  final BoxFit fit;

  /// Border radius for the image
  final BorderRadius? borderRadius;

  /// Placeholder icon when loading or no image
  final IconData placeholderIcon;

  /// Placeholder icon size
  final double placeholderIconSize;

  /// Background color for placeholder
  final Color? placeholderColor;

  /// Whether to show loading indicator
  final bool showLoadingIndicator;

  const NetworkImageWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholderIconSize = 40,
    this.placeholderColor,
    this.showLoadingIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor ?? AppColors.grey100,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          size: placeholderIconSize,
          color: AppColors.textHint,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: placeholderColor ?? AppColors.grey100,
          borderRadius: borderRadius,
        ),
        child: showLoadingIndicator
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  placeholderIcon,
                  size: placeholderIconSize,
                  color: AppColors.textHint,
                ),
              ),
      ),
      errorWidget: (context, url, error) => placeholder,
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// Circular avatar with network image
class NetworkAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData placeholderIcon;
  final Color? backgroundColor;

  const NetworkAvatarWidget({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.placeholderIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppColors.grey100,
        child: Icon(
          placeholderIcon,
          size: radius,
          color: AppColors.textSecondary,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppColors.grey100,
        child: SizedBox(
          width: radius,
          height: radius,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppColors.grey100,
        child: Icon(
          placeholderIcon,
          size: radius,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
