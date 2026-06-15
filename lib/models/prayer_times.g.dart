// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimesAdapter extends TypeAdapter<PrayerTimes> {
  @override
  final int typeId = 2;

  @override
  PrayerTimes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimes(
      date: fields[0] as DateTime,
      fajr: fields[1] as String,
      sunrise: fields[2] as String,
      dhuhr: fields[3] as String,
      asr: fields[4] as String,
      maghrib: fields[5] as String,
      isha: fields[6] as String,
      imsak: fields[7] as String,
      midnight: fields[8] as String,
      firstThird: fields[9] as String,
      lastThird: fields[10] as String,
      method: fields[11] as String,
      school: fields[12] as String,
      latitude: fields[13] as double,
      longitude: fields[14] as double,
      timezone: fields[15] as String,
      hijriDate: fields[16] as HijriDate,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimes obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.fajr)
      ..writeByte(2)
      ..write(obj.sunrise)
      ..writeByte(3)
      ..write(obj.dhuhr)
      ..writeByte(4)
      ..write(obj.asr)
      ..writeByte(5)
      ..write(obj.maghrib)
      ..writeByte(6)
      ..write(obj.isha)
      ..writeByte(7)
      ..write(obj.imsak)
      ..writeByte(8)
      ..write(obj.midnight)
      ..writeByte(9)
      ..write(obj.firstThird)
      ..writeByte(10)
      ..write(obj.lastThird)
      ..writeByte(11)
      ..write(obj.method)
      ..writeByte(12)
      ..write(obj.school)
      ..writeByte(13)
      ..write(obj.latitude)
      ..writeByte(14)
      ..write(obj.longitude)
      ..writeByte(15)
      ..write(obj.timezone)
      ..writeByte(16)
      ..write(obj.hijriDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
