import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../Pages/Home/models/video_data.dart';
import 'native_service.dart';
import 'performance_service.dart';

class PrecacheService {
  static final PrecacheService _instance = PrecacheService._internal();
  factory PrecacheService() => _instance;
  PrecacheService._internal();

  final Set<String> _precachedUrls = {};

  /// Precaches images and prepares video cache for the given list of videos.
  /// This can be called from providers or background tasks.
  Future<void> precacheVideoAssets(List<VideoData> videos) async {
    for (var video in videos) {
      // 1. Precache Profile Avatar
      if (video.avatarUrl.isNotEmpty && !_precachedUrls.contains(video.avatarUrl)) {
        _download(video.avatarUrl);
      }

      // 2. Precache Slideshow Images if it's an image post
      if (video.isImage && video.images != null) {
        for (var imgUrl in video.images!) {
          if (!_precachedUrls.contains(imgUrl)) {
            _download(imgUrl);
          }
        }
      }

      // 3. Warm up video cache (trigger download of initial segments)
      if (!video.isImage && video.url.isNotEmpty && !_precachedUrls.contains(video.url)) {
        _download(video.url);
      }
    }
  }

  void _download(String url) {
    // Basic Thermal-Aware Check: If memory is under extreme pressure, skip non-essential preloading
    PerformanceService().getMemoryInfo().then((info) {
      if (info != null && info['lowMemory'] == true) {
        return;
      }
      
      _precachedUrls.add(url);
      DefaultCacheManager().downloadFile(url).catchError((_) {
        _precachedUrls.remove(url);
      });
    });
  }

  /// Performs an aggressive native memory purge if high RAM pressure is detected.
  Future<void> handleSystemPressure() async {
    final info = await PerformanceService().getMemoryInfo();
    if (info != null && (info['lowMemory'] == true)) {
      nativeService.nativeOptimizeMemory();
      await DefaultCacheManager().emptyCache();
      _precachedUrls.clear();
    }
  }

  void clearTracker() {
    _precachedUrls.clear();
  }
}

final precacheService = PrecacheService();
