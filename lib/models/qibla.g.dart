// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qibla.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QiblaDirectionAdapter extends TypeAdapter<QiblaDirection> {
  @override
  final int typeId = 9;

  @override
  QiblaDirection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QiblaDirection(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      direction: fields[2] as double,
      distance: fields[3] as double,
      calculatedAt: fields[4] as DateTime,
      method: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QiblaDirection obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.direction)
      ..writeByte(3)
      ..write(obj.distance)
      ..writeByte(4)
      ..write(obj.calculatedAt)
      ..writeByte(5)
      ..write(obj.method);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QiblaDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
