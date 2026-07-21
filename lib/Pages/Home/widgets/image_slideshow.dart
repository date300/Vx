import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Upload/widgets/vx_premium_loader.dart';
import '../../../Services/native_service.dart';

class ZeroSlopHorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  ZeroSlopHorizontalDragGestureRecognizer({super.debugOwner});

  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);
    if (event is PointerMoveEvent) {
      if (event.delta.dx.abs() > 0.1 && event.delta.dx.abs() > event.delta.dy.abs()) {
        resolve(GestureDisposition.accepted);
      }
    }
  }

  @override
  bool isPointerAllowed(PointerEvent event) => true;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void rejectGesture(int pointer) {
    debugPrint("ZeroSlopHorizontal: REJECTED by parent");
    super.rejectGesture(pointer);
  }
}

class ImageSlideshow extends StatefulWidget {
  final List<String> images;
  const ImageSlideshow({super.key, required this.images});

  @override
  State<ImageSlideshow> createState() => _ImageSlideshowState();
}

class _ImageSlideshowState extends State<ImageSlideshow> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    
    return RepaintBoundary(
      child: RawGestureDetector(
        gestures: {
          ZeroSlopHorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<ZeroSlopHorizontalDragGestureRecognizer>(
            () => ZeroSlopHorizontalDragGestureRecognizer(),
            (instance) {
              instance.onStart = (details) {
                debugPrint("Slideshow: onStart at ${details.localPosition}");
                nativeService.processTouchEvent(0, 0, details.localPosition.dx, details.localPosition.dy, DateTime.now().millisecondsSinceEpoch);
              };
              instance.onUpdate = (details) {
                nativeService.processTouchEvent(0, 1, details.localPosition.dx, details.localPosition.dy, DateTime.now().millisecondsSinceEpoch);
                final delta = nativeService.getNativeScrollDeltaX();
                if (delta != 0 && _pageController.hasClients) {
                  // debugPrint("Slideshow: deltaX=$delta");
                  _pageController.position.jumpTo((_pageController.position.pixels - delta).clamp(0.0, _pageController.position.maxScrollExtent));
                }
              };
              instance.onEnd = (details) {
                debugPrint("Slideshow: onEnd");
                nativeService.processTouchEvent(0, 2, 0, 0, DateTime.now().millisecondsSinceEpoch);
                final velocity = nativeService.getNativeVelocity();
                final position = _pageController.position.pixels;
                final viewport = _pageController.position.viewportDimension;
                
                double currentPage = _pageController.page ?? _currentPage.toDouble();
                int targetPage;
                
                if (velocity.abs() > 400) {
                  targetPage = velocity < 0 ? currentPage.ceil() : currentPage.floor();
                } else {
                  targetPage = (position / viewport).round();
                }
                
                targetPage = targetPage.clamp(0, widget.images.length - 1);
                _pageController.animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
              };
            },
          ),
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.contain,
                        width: size.width,
                        height: size.height,
                        placeholder: (context, url) => const Center(child: VxPremiumLoader(color: Colors.white24)),
                        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white24),
                      ),
                    ),
                  );
                },
              ),
            ),

          // TikTok-style Photo Indicator & Counter (Top Right)
          if (widget.images.length > 1)
            Positioned(
              top: topPadding + 60, // Positioned below top bar
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "${_currentPage + 1}/${widget.images.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (widget.images.length > 1)
            Positioned(
              bottom: 120, // Moved from top: 100 to bottom: 120
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  return Container(
                    width: 6.0,
                    height: 6.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: _currentPage == entry.key ? 0.9 : 0.4),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
