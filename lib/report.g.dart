// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 1;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Report(
      companyName: fields[0] as String,
      equipmentName: fields[1] as String,
      modal: fields[2] as String,
      serialNumber: fields[3] as String,
      id: fields[4] as String,
      year: fields[5] as String,
      lastTUV: fields[6] as String,
      capcity: fields[7] as String,
      typeInspection: fields[8] as String,
      dateOfSubmit: fields[9] as DateTime?,
      timeSheet: fields[10] as String,
      result: fields[11] as String?,
      location: fields[12] as String,
      comments: fields[13] as String,
      validation: fields[14] as String?,
      stickerNumber: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.companyName)
      ..writeByte(1)
      ..write(obj.equipmentName)
      ..writeByte(2)
      ..write(obj.modal)
      ..writeByte(3)
      ..write(obj.serialNumber)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.year)
      ..writeByte(6)
      ..write(obj.lastTUV)
      ..writeByte(7)
      ..write(obj.capcity)
      ..writeByte(8)
      ..write(obj.typeInspection)
      ..writeByte(9)
      ..write(obj.dateOfSubmit)
      ..writeByte(10)
      ..write(obj.timeSheet)
      ..writeByte(11)
      ..write(obj.result)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.comments)
      ..writeByte(14)
      ..write(obj.validation)
      ..writeByte(15)
      ..write(obj.stickerNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
