import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';

/// Restaurant image gallery screen
class RestaurantGalleryScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final List<String>? initialImages;
  final int initialIndex;

  const RestaurantGalleryScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.initialImages,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<RestaurantGalleryScreen> createState() =>
      _RestaurantGalleryScreenState();
}

class _RestaurantGalleryScreenState
    extends ConsumerState<RestaurantGalleryScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getImages() {
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      return widget.initialImages!;
    }

    final restaurantState = ref.read(restaurantDetailsProvider);
    final restaurant = restaurantState.restaurant;

    if (restaurant == null) return [];

    final images = <String>[];
    if (restaurant.coverImage != null) {
      images.add(restaurant.coverImage!);
    }
    if (restaurant.logo != null && !images.contains(restaurant.logo)) {
      images.add(restaurant.logo!);
    }
    images.addAll(restaurant.images.where((img) => !images.contains(img)));

    return images;
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();

    if (images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('صور ${widget.restaurantName}'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 80,
                color: AppColors.textHint.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد صور',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'لم يتم إضافة صور لهذا المطعم بعد',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isFullScreen) {
      return _buildFullScreenGallery(images);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'صور ${widget.restaurantName}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () => _showGridView(images),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main gallery view
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isFullScreen = true;
                });
              },
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(images[index]),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
                  );
                },
                itemCount: images.length,
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? null
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                    color: Colors.white,
                  ),
                ),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),

          // Image counter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_currentIndex + 1} / ${images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),

          // Thumbnail strip
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: const Icon(Icons.error, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenGallery(List<String> images) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
              );
            },
            itemCount: images.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isFullScreen = false;
                });
              },
            ),
          ),

          // Image counter
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGridView(List<String> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'جميع الصور (${images.length})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Grid
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _pageController.jumpToPage(index);
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          child: Hero(
                            tag: 'grid_${images[index]}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.background,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.background,
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// A widget that displays a gallery preview card
class GalleryPreviewCard extends StatelessWidget {
  final List<String> images;
  final String restaurantName;
  final String restaurantId;
  final VoidCallback? onTap;

  const GalleryPreviewCard({
    super.key,
    required this.images,
    required this.restaurantName,
    required this.restaurantId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayImages = images.take(4).toList();
    final remainingCount = images.length - 4;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'الصور',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onTap,
                  child: Text('عرض الكل (${images.length})'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  ...List.generate(
                    displayImages.length,
                    (index) {
                      final isLast = index == displayImages.length - 1;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: index > 0 ? 4 : 0,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: displayImages[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.background,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppColors.background,
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                              ),
                              if (isLast && remainingCount > 0)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    child: Center(
                                      child: Text(
                                        '+$remainingCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
