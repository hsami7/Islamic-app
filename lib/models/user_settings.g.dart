// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 10;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      language: fields[0] as String,
      isDarkMode: fields[1] as bool,
      calculationMethod: fields[2] as int,
      madhab: fields[3] as int,
      notificationsEnabled: fields[4] as bool,
      fajrNotification: fields[5] as bool,
      dhuhrNotification: fields[6] as bool,
      asrNotification: fields[7] as bool,
      maghribNotification: fields[8] as bool,
      ishaNotification: fields[9] as bool,
      notificationAdvanceMinutes: fields[10] as int,
      quranAudioAutoPlay: fields[11] as bool,
      quranReciter: fields[12] as String,
      quranFontSize: fields[13] as double,
      showTranslation: fields[14] as bool,
      translationLanguage: fields[15] as String,
      showTafsir: fields[16] as bool,
      tafsirSource: fields[17] as String,
      useSystemLocale: fields[18] as bool,
      themeMode: fields[19] as int,
      hapticFeedback: fields[20] as bool,
      reduceMotion: fields[21] as bool,
      lastLocationLat: fields[22] as String,
      lastLocationLng: fields[23] as String,
      lastLocationCity: fields[24] as String,
      locationPermissionGranted: fields[25] as bool,
      compassCalibrated: fields[26] as bool,
      lastCompassCalibration: fields[27] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(28)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.isDarkMode)
      ..writeByte(2)
      ..write(obj.calculationMethod)
      ..writeByte(3)
      ..write(obj.madhab)
      ..writeByte(4)
      ..write(obj.notificationsEnabled)
      ..writeByte(5)
      ..write(obj.fajrNotification)
      ..writeByte(6)
      ..write(obj.dhuhrNotification)
      ..writeByte(7)
      ..write(obj.asrNotification)
      ..writeByte(8)
      ..write(obj.maghribNotification)
      ..writeByte(9)
      ..write(obj.ishaNotification)
      ..writeByte(10)
      ..write(obj.notificationAdvanceMinutes)
      ..writeByte(11)
      ..write(obj.quranAudioAutoPlay)
      ..writeByte(12)
      ..write(obj.quranReciter)
      ..writeByte(13)
      ..write(obj.quranFontSize)
      ..writeByte(14)
      ..write(obj.showTranslation)
      ..writeByte(15)
      ..write(obj.translationLanguage)
      ..writeByte(16)
      ..write(obj.showTafsir)
      ..writeByte(17)
      ..write(obj.tafsirSource)
      ..writeByte(18)
      ..write(obj.useSystemLocale)
      ..writeByte(19)
      ..write(obj.themeMode)
      ..writeByte(20)
      ..write(obj.hapticFeedback)
      ..writeByte(21)
      ..write(obj.reduceMotion)
      ..writeByte(22)
      ..write(obj.lastLocationLat)
      ..writeByte(23)
      ..write(obj.lastLocationLng)
      ..writeByte(24)
      ..write(obj.lastLocationCity)
      ..writeByte(25)
      ..write(obj.locationPermissionGranted)
      ..writeByte(26)
      ..write(obj.compassCalibrated)
      ..writeByte(27)
      ..write(obj.lastCompassCalibration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookmarkAdapter extends TypeAdapter<Bookmark> {
  @override
  final int typeId = 11;

  @override
  Bookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bookmark(
      id: fields[0] as String,
      type: fields[1] as String,
      surahNumber: fields[2] as int,
      ayahNumber: fields[3] as int,
      azkarId: fields[4] as String,
      note: fields[5] as String,
      createdAt: fields[6] as DateTime,
      metadata: (fields[7] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Bookmark obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.surahNumber)
      ..writeByte(3)
      ..write(obj.ayahNumber)
      ..writeByte(4)
      ..write(obj.azkarId)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
