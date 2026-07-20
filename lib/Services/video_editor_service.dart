import 'package:path_provider/path_provider.dart';
import 'native_service.dart';

class VideoEditorService {
  static Future<String?> trimVideo({
    required String inputPath,
    required double startTime,
    required double duration,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final inputPtr = inputPath.toNativeUtf8();
    final outputPtr = outputPath.toNativeUtf8();

    try {
      final result = nativeService.trimVideo(inputPtr, outputPtr, startTime, duration);
      if (result == 0) {
        return outputPath;
      }
      return null;
    } finally {
      calloc.free(inputPtr);
      calloc.free(outputPtr);
    }
  }
}
