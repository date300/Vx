import 'package:hive_flutter/hive_flutter.dart';

class VideoDraft {
  final String id;
  final String videoPath;
  final String caption;
  final String? soundTitle;
  final double coverTimestamp;
  final DateTime createdAt;

  VideoDraft({
    required this.id,
    required this.videoPath,
    required this.caption,
    this.soundTitle,
    required this.coverTimestamp,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoPath': videoPath,
    'caption': caption,
    'soundTitle': soundTitle,
    'coverTimestamp': coverTimestamp,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VideoDraft.fromJson(Map<String, dynamic> json) => VideoDraft(
    id: json['id'],
    videoPath: json['videoPath'],
    caption: json['caption'],
    soundTitle: json['soundTitle'],
    coverTimestamp: (json['coverTimestamp'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class DraftService {
  static const String _boxName = 'drafts_cache';

  static Future<void> saveDraft(VideoDraft draft) async {
    final box = Hive.box(_boxName);
    await box.put(draft.id, draft.toJson());
  }

  static List<VideoDraft> getDrafts() {
    final box = Hive.box(_boxName);
    return box.values
        .map((e) => VideoDraft.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> deleteDraft(String id) async {
    final box = Hive.box(_boxName);
    await box.delete(id);
  }
}
