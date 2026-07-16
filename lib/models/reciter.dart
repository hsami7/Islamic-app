/// Reciter definitions for Quran audio playback.
///
/// Audio URLs follow the verses.quran.com CDN pattern:
///   https://verses.quran.com/{reciterDir}/{ayahNumber}.mp3
///
/// The default app audio previously used the bare `verses.quran.com/{n}.mp3`
/// (Alafasy). We now expose a reciter list and build the URL from [audioDir].
class Reciter {
  const Reciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.audioDir,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String audioDir;

  static const List<Reciter> all = [
    Reciter(
      id: 'yasser_al_dosari',
      nameAr: 'ياسر الدوسري',
      nameEn: 'Yasser Al-Dosari',
      audioDir: 'Yasser_Al_Dosari_128kbps',
    ),
    Reciter(
      id: 'alafasy',
      nameAr: 'مشاري العفاسي',
      nameEn: 'Mishary Alafasy',
      audioDir: 'Alafasy_128kbps',
    ),
    Reciter(
      id: 'abdul_basit',
      nameAr: 'عبد الباسط عبد الصمد',
      nameEn: 'Abdul Basit',
      audioDir: 'Abdul_Basit_Murattal_128kbps',
    ),
    Reciter(
      id: 'sudais',
      nameAr: 'عبد الرحمن السديس',
      nameEn: 'Abdurrahman As-Sudais',
      audioDir: 'Abdurrahmaan_As-Sudais_128kbps',
    ),
    Reciter(
      id: 'husary',
      nameAr: 'محمود خليل الحصري',
      nameEn: 'Mahmoud Khalil Al-Husary',
      audioDir: 'Husary_128kbps',
    ),
  ];

  static Reciter byId(String id) =>
      all.firstWhere((r) => r.id == id, orElse: () => all.first);

  /// Build the audio URL for a global ayah number.
  String audioUrl(int ayahGlobalNumber) =>
      'https://verses.quran.com/$audioDir/$ayahGlobalNumber.mp3';
}
