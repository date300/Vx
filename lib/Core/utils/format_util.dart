class FormatUtil {
  static String formatNumber(int count) {
    if (count >= 1000000000) {
      return "${(count / 1000000000).toStringAsFixed(1)}B".replaceAll('.0B', 'B');
    }
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M".replaceAll('.0M', 'M');
    }
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K".replaceAll('.0K', 'K');
    }
    return count.toString();
  }
}
