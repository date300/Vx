class VxSound {
  final String id;
  final String title;
  final String artist;
  final String url;
  final String coverUrl;
  final Duration duration;

  VxSound({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.coverUrl,
    required this.duration,
  });
}

class SoundService {
  static List<VxSound> getTrendingSounds() {
    return [
      VxSound(
        id: "1",
        title: "Summer Vibes",
        artist: "Chill Master",
        url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        coverUrl: "https://api.dicebear.com/7.x/identicon/svg?seed=Summer",
        duration: const Duration(seconds: 30),
      ),
      VxSound(
        id: "2",
        title: "Midnight Drive",
        artist: "Synth Boy",
        url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        coverUrl: "https://api.dicebear.com/7.x/identicon/svg?seed=Midnight",
        duration: const Duration(seconds: 45),
      ),
      VxSound(
        id: "3",
        title: "Happy Days",
        artist: "Upbeat Crew",
        url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
        coverUrl: "https://api.dicebear.com/7.x/identicon/svg?seed=Happy",
        duration: const Duration(seconds: 28),
      ),
      VxSound(
        id: "4",
        title: "Ocean Breeze",
        artist: "Nature Sounds",
        url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
        coverUrl: "https://api.dicebear.com/7.x/identicon/svg?seed=Ocean",
        duration: const Duration(seconds: 60),
      ),
      VxSound(
        id: "5",
        title: "Urban Jungle",
        artist: "Street Beats",
        url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
        coverUrl: "https://api.dicebear.com/7.x/identicon/svg?seed=Urban",
        duration: const Duration(seconds: 35),
      ),
    ];
  }

  static List<VxSound> searchSounds(String query) {
    if (query.isEmpty) return getTrendingSounds();
    return getTrendingSounds().where((s) => 
      s.title.toLowerCase().contains(query.toLowerCase()) || 
      s.artist.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
